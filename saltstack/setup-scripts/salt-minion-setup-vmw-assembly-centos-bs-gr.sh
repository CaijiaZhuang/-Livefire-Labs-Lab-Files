#--------------------------------------------------------#
#                     Spas Kaloferov                     #
#                   www.kaloferov.com                    #
# bit.ly/The-Twitter      Social     bit.ly/The-LinkedIn #
# bit.ly/The-Gitlab        Git        bit.ly/The-Youtube #
# bit.ly/The-BSD         License          bit.ly/The-GNU #
#--------------------------------------------------------#

  #
  #              Shell Script Code Sample     
  #
  #  - Installs SaltStack minion using bootstrap
  #  - Accepts all install_salt.sh arguments
  #  - Allows to set default args if not specified
  #  - Adds grains file and enables autosign_grains
  #  

# ---------------- Process Parameters ----------------- #

## ARGS METHOD 2 - Pass all args
# Save all parameters inputs in a single arg and pass it later to the salt install
saltArgs=""
for arg in $@
do
    saltArgs+=" $arg "
done

# Set some default param(s) if not provided
if [[ $saltArgs != *"-A"* ]]; then saltArgs+=" -A saltstack.livefire.dev "; fi
if [[ $saltArgs != *"-x"* ]]; then saltArgs+=" -x python3 "; fi

# -------------- Install SaltStack Minion -------------- #

# Donwload and install via bootstrap. 
cd /tmp
curl -L 'https://bootstrap.saltstack.com' -o install_salt.sh
sudo sh install_salt.sh $saltArgs

# -------- Enable Autoaccept minions from Grains ------- #

cd /etc/salt/

# Create Minion Grains file if it does not exist
file_grians='/etc/salt/grains'
if [ -f "$file_grians" ]; then
    echo "[INFO]: Grains file $file_grians exists."
else 
    echo "[INFO]: Grains file $file_grians does not exist. Creating ..."
    touch grains
    echo "#" >> grains
fi

# Add Grain(s) to Grains file
echo "[INFO]: Adding Grain(s) to Grain file..."
sed -i -e '$avmw_securestate_compliance:\ compliant' grains

# enable autosign_grains
echo "[INFO]: Enabling autosign_grains..."
sed -i 's/#autosign_grains:/autosign_grains:/g' minion

# Add custom grain(s) and account for empty spaces for proper format 
echo "[INFO]: Adding Grain(s) to autosign_grains..."
sed -i '/autosign_grains:/a\ \ -\ vmw_securestate_compliance' minion

# Add packages needed for Reactor SLS's :
pip3 install pyinotify
pip3 install inotify 

# Restart Minion services to initiate nuw authentication 
echo "[INFO]: Restarting Minion service..."
systemctl restart salt-minion

# ---------------------- Appendix ---------------------- #

## References: 
# - Autoaccept minions from Grains https://docs.saltstack.com/en/latest/topics/tutorials/autoaccept_grains.html#tutorial-autoaccept-grains
# - Named Parameters In Bash https://brianchildress.co/named-parameters-in-bash/
