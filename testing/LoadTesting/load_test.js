import http from 'k6/http';
import { check, group, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 10 }, // Ramp-up to 10 users over 1 minute
    { duration: '5m', target: 50 }, // Sustain 50 users for 5 minutes
    { duration: '1m', target: 0 },  // Ramp-down
  ],
};

const accessToken = "###accessToken###";
const idToken = "eyJraWQiOiJGS3J0V29YQVhhSzYya1ZjMWxlbjdVMjhyWlwvWnNhcG1iNW5RbkhcL0t1NzQ9IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI5NGI4YTRmOC00MGMxLTcwMjYtNWQzZC05YmRjZGUxNDk4MjUiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV94QjFVcDNDd3ciLCJ2ZXJzaW9uIjoyLCJjbGllbnRfaWQiOiI0Z3BiZWZlb2ppZTVrNmpobWRsaGZ1OWtkMiIsIm9yaWdpbl9qdGkiOiIxNjhiNWVhYy1lZDhlLTQ3MGUtOWVlOC1kMjMyNjBlN2U5OGYiLCJ0b2tlbl91c2UiOiJhY2Nlc3MiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwiYXV0aF90aW1lIjoxNzMzMjM1NDM5LCJleHAiOjE3MzMyMzkwMzksImlhdCI6MTczMzIzNTQzOSwianRpIjoiN2MwYmI0OGItODc5YS00NmU4LWFhY2QtODExZmMzY2VhY2MzIiwidXNlcm5hbWUiOiJhYmR1bGFoYWQifQ.RiakFmm1PhKIvfCV2iBz7b1dK9AGuKta78ErQjmr4GnogXENbUldAhCUPWjhSW6VokxsNbGj7R0-fC94XqDnBmC3BOyX-eXN50mfOaDhqS4DMJTiCOi00bEPOGogst41S6Nw5ALjHkrTPB4kW-MQ555ddijhtokQaI0rEZThe_cURlrmyr_mhelkbnZPmD6Bd_Y0Y6ZRzexIGOWgCG-7RM4S9fHpN3Zph87XySz5Bxuo1hOmwBZuaJ9pfA-ACjNNQVI0gSjsALTy__JfsGGr29OROjVfqZFqExO3fPPwjf6_RGVX3mIoqsh6CrRWzy7D7E-QO6RiCPhBnyFxnW0BuA";
const getSignedUrlEndpoint = "https://s6xl5rp7mf.execute-api.us-east-1.amazonaws.com/prod/upload-photo";
const searchImageEndpoint = "https://m82xphu4lf.execute-api.us-east-1.amazonaws.com/prod/search";

export default function () {
  group('Generate Pre-Signed URL', function () {
    const res = http.post(getSignedUrlEndpoint, {}, {
      headers: {
        Authorization: idToken,
        'Content-Type': 'application/json',
      },
    });

    check(res, {
      'Pre-Signed URL received': (r) => r.status === 200,
    });

    if (res.status === 200) {
      const result = JSON.parse(res.body);

      // Simulate the S3 upload process
      group('Upload File to S3', function () {
        const formData = {
          key: result.fields.key,
          AWSAccessKeyId: result.fields.AWSAccessKeyId,
          'x-amz-security-token': result.fields['x-amz-security-token'],
          policy: result.fields.policy,
          signature: result.fields.signature,
          file: http.file('test-image.jpg', 'image/jpeg'),
        };

        const uploadRes = http.post(result.url, formData);

        check(uploadRes, {
          'File uploaded successfully': (r) => r.status === 204,
        });
      });
    }
  });

  group('Search Images by Label', function () {
    const payload = JSON.stringify({
      label: 'testLabel',
      language: 'en',
      country: 'US',
      source: 'API',
    });

    const res = http.post(searchImageEndpoint, payload, {
      headers: {
        Authorization: idToken,
        'Content-Type': 'application/json',
      },
    });

    check(res, {
      'Search successful': (r) => r.status === 200,
    });
  });

  sleep(1); // Pause between iterations
}
