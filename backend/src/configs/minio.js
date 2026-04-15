const Minio = require('minio');

const minioClient = new Minio.Client({
  endPoint: 'localhost',
  port: 9000,
  useSSL: false,
  accessKey: 'minioadmin',
  secretKey: 'minioadmin',
});

const BUCKET_NAME = 'bucket-social-network-together';

// Делаем bucket публичным
const setBucketPublic = async () => {
  const policy = {
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: { AWS: ["*"] },
        Action: ["s3:GetObject"],
        Resource: [`arn:aws:s3:::${BUCKET_NAME}/*`]
      }
    ]
  };
  
  try {
    await minioClient.setBucketPolicy(BUCKET_NAME, JSON.stringify(policy));
  } catch (error) {
    console.error(`❌ Ошибка установки политики: ${error.message}`);
  }
};

// Проверяем существование bucket и делаем его публичным
const initBucket = async () => {
  const exists = await minioClient.bucketExists(BUCKET_NAME);
  if (exists) {
    await setBucketPublic();
  } else {
    console.error(`❌ Bucket ${BUCKET_NAME} не существует`);
  }
};

initBucket();

module.exports = { minioClient, BUCKET_NAME };