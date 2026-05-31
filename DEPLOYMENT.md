# Deployment Documentation

## Cloud Provider

**AWS** — EC2 `t2.micro` instance in `us-east-1`.

Chosen because it is free-tier eligible and straightforward to set up for a single-container workload.

---

## Virtual Machine Setup

1. Launched an EC2 `t2.micro` instance running **Ubuntu 24.04 LTS** via the AWS console.
2. Created a security group with the following inbound rules:
   - Port **80** (HTTP) open to `0.0.0.0/0`
   - Port **22** (SSH) open to my IP only
3. Downloaded the `.pem` key pair during instance creation.

---

## Installing Docker

Connected to the instance via SSH and ran:

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
```

---

## How the Image Gets to the Server

The GitHub Actions pipeline handles this automatically on every push to `main`:

1. Runs `npm test` — stops if tests fail
2. Builds the Docker image and tags it with the Git commit SHA
3. Pushes the image to GitHub Container Registry (GHCR)
4. SSHs into the EC2 instance, pulls the new image, and restarts the container

The container is started with:

```bash
docker run -d \
  --name deployready \
  --restart unless-stopped \
  -p 80:3000 \
  -e PORT=3000 \
  ghcr.io/gilbmura/deployready:<commit-sha>
```

---

## Checking if the Container is Running

```bash
docker ps
```

You should see the `deployready` container with status `Up`.

---

## Viewing Application Logs

```bash
docker logs deployready
```

To follow logs in real time:

```bash
docker logs -f deployready
```
