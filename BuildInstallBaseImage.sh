#!/sh/bin
ZEDEDA=$HOME/go/src/github.com/zededa
TAG=kalyan-pci-back
ZCLI_CONFIG_CMD="zcli configure -s zedcontrol.canary.zededa.net  -u kalyan@zenixcorp.com -P Kalyan@123 -O text"
DEVICE=sc-supermicro-zc1
ZCLI_ZEDEDA_PATH='/root/go/src/github.com/zededa'

cd $ZEDEDA/go-provision
docker build -t $TAG .

cd $ZEDEDA/zenbuild
ZTOOLS_TAG=$TAG make rootfs.img
IMAGE=`grep contents images/rootfs.yml | awk '{print $2}'`
echo "IMAGE=$IMAGE"
#contents: '0.0.0-fixes-6640a81b-dirty-2018-12-17.22.10-amd64'
#IMAGE='0.0.0-6640a81b-dirty-2018-12-18.23.51-amd64'

# Start zcli container. Skip this step if zcli container is already running.
docker pull zededa/zcli-dev:latest
docker run -v $HOME:/root -it --name zcli  zededa/zcli-dev:latest

docker restart zcli

# In ZCLI:
IMAGE_PATH="$ZCLI_ZEDEDA_PATH/zenbuild/rootfs.img"
echo "IMAGE_PATH = $IMAGE_PATH"
docker exec zcli /bin/sh -c "$ZCLI_CONFIG_CMD"
docker exec zcli /bin/sh -c "zcli login"
docker exec zcli /bin/sh -c "zcli image create --type=baseimage --image-format=qcow2 $IMAGE"
docker exec zcli /bin/sh -c "zcli image upload --datastore-name=Zededa-AWS-Image $IMAGE --path=$IMAGE_PATH"
docker exec zcli /bin/sh -c "zcli device baseimage-update $DEVICE --image=$IMAGE"
docker exec zcli /bin/sh -c "zcli device baseimage-update $DEVICE --image=$IMAGE --activate"
docker exec zcli /bin/sh -c "zcli device show --detail $DEVICE"
