# geekettes-scala
To build a docker image, install docker from the website and run 

```> docker build .```

Get the id of the image by running 

```> docker images```

Tag the docker image by running

```> docker tag <image_id> rrenjith/twitter-geekettes```

Run the docker image in a container by running

```> docker run -p 42222:22 -itd -v ~/work/docker-setup/temp:/home/geekettes/workspace twitter/geekettes:latest /bin/bash```

Setup SSH port forwarding by running 

```> ssh -p 42222 -L 8888:localhost:8888 geekettes@127.0.0.1```

Push the docker image to docker repo using

```> docker push rrenjith/twitter-geekettes```
