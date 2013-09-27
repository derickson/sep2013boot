
security="david.erickson.bootcamp"
keypair="david.erickson.ec2"
pemfile="davidericksonec2.pem"

## PEM file needs correct permissions already for this to work


function stepTag {

    # tag it
    args=()
    args+=($instance)
    args+=(--tag "Owner=david.erickson")
    args+=(--tag "Expire-on=2013-11-01")
    #args+=(--tag "Expire-on=immediately")
    args+=(--tag "Name=Erickson-Bootcamp-Sep13")
    ec2-create-tags ${args[*]}
}


function stepCreate {

    # set up security group
    # ec2-delete-group $security
    # ec2-create-group $security --description "Bruce Lucas bootcamp"
    # ec2-authorize $security -p 27017-27021
    # ec2-authorize $security -p 28017
    # ec2-authorize $security -p 22
    # ec2-authorize $security -p 4949
    # ec2-authorize $security -p 8080-8081
    # ec2-describe-group $security

    # # generate keypair
    # ec2-delete-keypair $keypair
    # ec2-create-keypair $keypair | sed -n '/BEGIN/,/END/p' >$keypair.pem
    # ec2-describe-keypairs | grep $keypair
    # chmod og-rw *.pem

    # generate instance
    args=()
    args+=(ami-05355a6c)                           # ???
    args+=(--instance-count 1)
    args+=(--instance-type m1.medium)
    args+=(--key $keypair)
    args+=(--group $security)
    args+=(--availability-zone us-east-1b)         # N Virginia
    args+=(--block-device-mapping "/dev/sdb=:250") # 250 GB EBS
    #args+=(--user-data-file userdata.sh)   # xxx this didn't work, so just use ssh -t
    ec2-run-instances ${args[*]}
}


function stepDescribe {
	# get the ip address
    ec2-describe-instances $instance
}

function stepPushKeyAndSetup {


	
    # authorize our personal key to simplify ssh
    cat ~/.ssh/id_rsa.pub | ssh -i $pemfile -o StrictHostKeyChecking=no ec2-user@$publichostname \
        'mkdir -p .ssh; chmod og-w .ssh; cat >>.ssh/authorized_keys'
    
    # do setup
    scp ./setup.sh ec2-user@$publichostname:.
    ssh -t ec2-user@$publichostname sudo bash ./setup.sh

    # copy more stuff over
    #scp -r mms-agent ec2-user@$ip:
    #scp ~/.emacs ec2-user@$ip:
}

#
# uncomment and execute the steps one at a time, manually substituting
# the info from each step into the variable assignment following ti
#

function refeshHostExports {
	export instance=`cat .ec2Instance`
	export publichostname=`cat .ec2publichostname`
	echo "I think your ec2 instance name is:" $instance
	echo "I think your ec2 hostname is:" $publichostname
	echo ""
}

function sleep60 {
	echo "Sleeping for 60 seconds waiting for the machine to stand up"
	echo "60"; sleep 10
	echo "50"; sleep 10
	echo "40"; sleep 10
	echo "30"; sleep 10
	echo "20"; sleep 10
	echo "10"; sleep 10
	echo "0"
}

stepCreate > pythonInput.log

python parseDescribe.py
refeshHostExports
stepTag
stepDescribe > pythonInput.log
python parseDescribe.py
refeshHostExports

sleep60

stepDescribe > pythonInput.log
python parseDescribe.py
refeshHostExports
echo "Host Description:"
stepDescribe
echo ""

echo "Pushing Key and Setting up"
stepPushKeyAndSetup

echo "Done"
