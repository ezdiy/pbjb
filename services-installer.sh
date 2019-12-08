#!/mnt/secure/su /bin/sh
PKGVER=v4
iv2sh SetActiveTask `pidof bookshelf.app` 0
dialog 1 "" "Do you wish to (re)install unix services version $PKGVER on this rooted device?" "Yes" "No"
if [ $? != 1 ]; then
	exit 0
fi
mkdir -p /mnt/ext1/public_html
echo "*.html files are served from here if 'HTTP server' option is enabled. dynamic pages can be served by *.cgi scripts." > /mnt/ext1/public_html/index.html
mkdir /mnt/ext1/public
echo 'Files in here are served to public via smb:\\pocketbook\public, ftp://anonymous@pocketbook and http://pocketbook/public/' > /mnt/ext1/public/README.txt
mkdir /mnt/ext1/.ssh
mkdir /mnt/ext1/system/init.d
mkdir -p /mnt/ext1/system/config/settings

ARCHIVE=`awk '/^__DATA/ {print NR + 1; exit 0; }' $0`
chattr -i /mnt/secure/runonce/*.sh
tail -n+$ARCHIVE $0 | tar xz -C /mnt/secure
chattr +i /mnt/secure/runonce/*.sh /mnt/secure/su
if [ ! -e /mnt/secure/etc/passwd ]; then
	PW=$RANDOM
	echo -n password=$PW > /mnt/ext1/rootpassword.txt
fi

base=/mnt/ext1/system/config/settings
settings=$base/settings.json
rootset=$base/rootsettings.json
old=/ebrmain/config/settings/settings.json 

if [ -e $settings ] && ! grep rootsettings $settings> /dev/null; then
	old=$settings.old
	mv -f $settings $old
fi

if [ ! -e $settings ]; then
        cat <<_EOF > $settings
[

        {
                "control_type" : "submenu",
                "icon_id"      : "ci_system",
                "from_file"    : "./rootsettings.json",
                "title_id"     : "Rooted device settings",
        },
_EOF
        tail -n +2 $old >> $settings
fi

cat <<_EOF > $rootset
[
        {
                "control_type" : "executable",
                "icon_id" : "ci_swupdate",
                "id" : "rootapply",
                "storage" : [ "/mnt/secure/bin/applysettings.app" ],
                "title_id" : "Reboot to apply changes"
        },
        {
                "id"            :   "password_set",
                "title_id"      :   "Root password",
                "control_type"  :   "edit",
                "kind"          :   "text",
                "default"       :   "(keep unchanged)",
                "storage"       :   ["/mnt/ext1/rootpassword.txt, password"],
        }
_EOF
for n in /mnt/secure/init.d/*.sh; do
        desc="$(head -2 $n | tail -1)"
        if [ "${desc:0:2}" != "##" ]; then
                continue
        fi
        desc=${desc:2}
	n=${n##*/}
        bn=${n:3}
        id=${bn/.sh/}
        cat <<_EOF >> $rootset
        ,{
                "id": "root_$id",
                "storage" : [ "\${SYSTEM_CONFIG_PATH}/rootsettings.cfg, $id" ],
                "values" : [ ":0:@Off", ":1:@On" ],
                "control_type" : "switch",
                "kind": "none",
                "default" : ":1:@On",
                "title_id" : "$desc",
        }
_EOF
done
echo "]" >> $rootset



sync
dialog 1 "" "Services installed, restart is needed to get em running." "Restart now" "Will restart manually"
if [ $? == 1 ]; then
	/sbin/reboot
fi
exit 0
__DATA
