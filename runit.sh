docker run \
  --name temp \
  -it \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  rustmtcnn $* # bash

#docker container inspect temp
docker container cp temp:/tmp/test.jpg ./
docker container rm temp
 