# Pixplore - Picture Recognition and Search System

## Project Overview

Pixplore is a Pinterest-like image gallery application designed to provide users with a seamless way to upload and search for images based on tags or visual content. It leverages AWS services to ensure a serverless, scalable, and secure environment that can handle high traffic and provide efficient, on-demand search functionality.

### Team Members
- Amaan Ahmed - 25100127
- Muhammad Shayan - 25100164
- Faizan Ullah - 23030015
- Ibrahim Ahmed Khan - 25100112
- Abdul Ahad Bin Ali - 25100016

---

## System Architecture

### AWS Architecture Diagram
![AWS Architecture Diagram](link_to_architecture_diagram.png)

### AWS Services Used

1. **AWS Virtual Private Cloud (VPC)** - Provides network isolation with access-controlled subnets for public and private resources.
2. **Elastic Load Balancer (ALB)** - Distributes incoming HTTP and HTTPS traffic, allowing the system to handle traffic spikes by scaling backend services horizontally.
3. **AWS Cognito** - Manages user authentication and access control securely.
4. **Amazon API Gateway** - Manages API routing and provides secure communication between users and backend services.
5. **Amazon Simple Storage Service (S3)** - Handles initial image upload directly to buckets, reducing backend workload.
6. **Amazon Lambda** - Serverless functions handle backend tasks, including image upload processing and metadata extraction.
7. **Amazon EventBridge** - Manages event-driven processing, triggering Lambda functions for metadata processing after image uploads.
8. **Amazon Simple Queue Service (SQS)** - Enables queue-based processing for asynchronous metadata handling.
9. **Amazon Rekognition** - Provides image analysis by extracting metadata (tags, labels, etc.) for future search functionality.
10. **Amazon Aurora (RDS)** - Stores structured metadata for efficient, on-demand retrieval and complex querying.
11. **Amazon Elastic Container Service (ECS) with Fargate** - Manages the scalable image search functionality using metadata in Aurora.
12. **Amazon CloudWatch** - Monitors system health, performance, and logs, enabling proactive scaling and troubleshooting.

---

## System Features

### Core Functionalities
- **User Authentication**: Secured via AWS Cognito, managing registration and login with JWT tokens for secure access.
- **Image Upload**: Users upload images directly to S3 through a presigned URL, minimizing backend load.
- **Image Search**: Users can search images by tags or visual attributes using ECS with Fargate and Amazon Rekognition.

### Scaling and Performance
- **Auto-Scaling**: Lambda functions and ECS containers are configured to auto-scale based on demand, ensuring optimal performance.
- **Traffic Management**: ALB and API Gateway distribute traffic efficiently to avoid throttling.
- **User Support**: Cognito initially supports up to 50,000 users, with scalability options available as demand increases.

---

## Expected Capacity

- **Concurrent Users**: Up to 1,000 concurrent users initially, with potential scalability up to 100,000.
- **Image Processing**: Capable of handling up to 10,000 images per hour, scalable to 100,000 images per hour.
- **User Limit**: Initial capacity for 50,000 users, scalable as needed.

---

## Getting Started

1. **Prerequisites**:
   - AWS Account with access to the above services.
   - Recommended to have basic knowledge of serverless architectures and AWS tools.

2. **Setup**:
   - Deploy AWS resources as per the architecture diagram.
   - Configure Cognito for user authentication and S3 for image storage.
   - Use the provided scripts (coming soon) to initialize and configure the environment.

---

## Future Enhancements

- **Advanced Metadata Search**: Implement additional filters and advanced query capabilities.
- **AI-based Image Recommendations**: Integrate a recommendation engine based on user preferences and search history.
- **Enhanced Security**: Continuously update security measures as the user base grows.

---

## Contributing

We welcome contributions from the community! If you'd like to contribute, please fork the repository and submit a pull request with a brief description of the changes made.

---

## License

This project is licensed under the MIT License.

### Image Building Steps

`docker build -t fastapi-search:latest .`
