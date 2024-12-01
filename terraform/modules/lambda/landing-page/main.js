const fs = require('fs');


exports.handler = async (event, context) => {
    try {
        const loginPage = event.headers.referer;

        // Retrieve environment variables
        const clientId = process.env.COGNITO_CLIENT_ID;
        const clientSecret = process.env.COGNITO_CLIENT_SECRET;
        const tokenUrl = process.env.COGNITO_TOKEN_URL;

        console.log("clientId: ", clientId)
        console.log("clientSecret: ", clientSecret)
        console.log("tokenUrl: ", tokenUrl)


        // Parse incoming event
        const queryStringParameters = event.queryStringParameters || {};
        const code = queryStringParameters.code;
        const redirectUri = "https://s6xl5rp7mf.execute-api.us-east-1.amazonaws.com/prod/landing-page"

        console.log("code: ", code)
        console.log("redirectUri: ", redirectUri)

        if (!code || !redirectUri) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: "Missing 'code' or 'redirect_uri' in request" }),
            };
        }

        const authCode = code;

        const response = await fetch(tokenUrl, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
            },
            body: new URLSearchParams({
                grant_type: "authorization_code",
                client_id: clientId,
                code: authCode,
                redirect_uri: redirectUri,
            }),
        });

        const data = await response.json();
        console.log("data: ", data)
        if (data.access_token) {
            // Store the access token for further API calls
            console.log("Access token received: ", data.access_token);
        } else {
            throw new Error(data.error_description || "Unknown error");
        }

        const accessToken = data.access_token;
        const idToken = data.id_token;

        const htmlContent = fs.readFileSync('index.html', 'utf8').replace('###loginPage###', loginPage).replace('###accessToken###', accessToken).replace('###idToken###', idToken);

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'text/html',
                'Access-Control-Allow-Origin': '*', // Allows all origins
                'Access-Control-Allow-Methods': 'GET, POST', // Add methods if necessary
                'Access-Control-Allow-Headers': 'Authorization', // Allow Authorization header
            },
            body: htmlContent,
        };
    } catch (error) {
        console.error("Error reading file or processing request:", error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
            },
            body: JSON.stringify({ error: 'Internal Server Error' }),
        };
    }
};
















// Redirect to the landing page with the token as a query parameter
//         const landingPage = `${redirectUri.split('prod/')[0]}prod/landing-page`;
//         return {
//             statusCode: 302,
//             headers: {
//                 Location: `${landingPage}?access_token=${accessToken}`,
//             },
//         };


//     } catch (error) {
//         console.error(error);
//         return {
//             statusCode: 500,
//             body: JSON.stringify({ error: error.message || 'Internal Server Error' }),
//         };
//     }
// };