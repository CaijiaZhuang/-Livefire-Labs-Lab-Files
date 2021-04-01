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
  #  - Adds Cloud Assembly Cloud Template dpeloyment info as Grains
  #  - Adds Custom User Input as Grains 
  #  
  # [Parameters] 
  #  - t (String|Optional): Adds Grains from Assembly Resource Tags e.g. cloudConfig: grainsTags="${self.tags}"
  #  - c (String|Optional): Adds Grains from Assembly Resource Constraints e.g. cloudConfig: grainsCons="${self.constraints}"
  #  - a (String|Optional): Adds Grains from a User Input Array e.g. cloudConfig: "grainsArray="${input.sseMinionGrains}"
  #  - l (String|Optional): Adds Grains from a string list. e.g. "grain1:value1,grain2:value2"

# ---------------- Process Parameters ----------------- #

while getopts t:c:a:l: flag
do
    case "${flag}" in
        t) param_tags=${OPTARG};;
        c) param_constraints=${OPTARG};;
        a) param_array=${OPTARG};;
        l) param_list=${OPTARG};;

    esac
done

# --------------- Add Top Level Grain ----------------- #

shopt -s lastpipe

cd /etc/salt/

# Create Minion Grains file if it does not exist
file_grians='/etc/salt/grains'
if [ -f "$file_grians" ]; then
    echo "[INFO]: Grains file $file_grians exists."
else 
    echo "[INFO]: Grains file $file_grians does not exist. Creating ..."
    touch grains
    echo "# Salt Grains File #" >> grains
fi

# Add Top Level Grain Name
echo "[INFO]: Adding Top Level Grain..."
sed -i -e '$avmw_cas_deployment_info:' grains

# ----------------- Add LIST Grains ------------------- #

# Add LIST Grains
#sed -i -e '$a\ \ requested_by:\ ${env.requestedBy}' grains
#sed -i -e '$a\ \ project_name:\ ${env.projectName}' grains
#sed -i -e '$a\ \ region:\ ${self.region}' grains
#sed -i -e '$a\ \ image:\ ${self.image}' grains
#sed -i -e '$a\ \ flavor:\ ${self.flavor}' grains
#sed -i -e '$a\ \ account:\ ${self.account}' grains

gr_list=$param_list
echo $gr_list | sed 's/:/','/g' | sed 's/[]]/''/g' | read gr_list

gr_list_arr=($(echo "$gr_list" | tr ',' '\n'))

echo "[INFO]: LIST Grains list: $gr_list"
echo "[INFO]: LIST Grains adding..."

for (( i=0; i<${#gr_list_arr[@]}; i=i+2 ));
do
   sed -i -e '$a\ \ '${gr_list_arr[$i]}':\ '${gr_list_arr[$i+1]}'' grains
done

# ----------------- Add TAGS Grains ------------------- #

# Add TAGS Grains
gr_tags=$param_tags
echo $gr_tags | sed 's/key\:/''/g' | sed 's/value\:/''/g' | sed 's/\[{/''/g' | sed 's/}\]/''/g' | sed 's/,/':'/g' | sed 's/}:{/','/g' | sed 's/\[\]/''/g' | read gr_tags

echo "[INFO]: TAGS Grains list: $gr_tags"
echo "[INFO]: TAGS Grains adding..."

sed -i -e '$a\ \ tags:\ '$gr_tags'' grains

# --------------- Add CONSTRAINT Grains --------------- #

# Add CONSTRAINT Grains
gr_cons=$param_constraints
echo $gr_cons | sed 's/tag\:/''/g' |  sed 's/\[{/''/g' | sed 's/}\]/''/g' |  sed 's/},{/','/g' | sed 's/\[\]/''/g' | read gr_cons

echo "[INFO]: CONSTRAINT Grains: $gr_cons"
echo "[INFO]: CONSTRAINT Grains adding..."

sed -i -e '$a\ \ constraints:\ '$gr_cons'' grains

# ----------------- Add ARRAY Grains ------------------ #

# Add ARRAY Grains 
#gr_array="[{"key":"cas-resource-source","value":"vra-cloud"},{"key":"cas-resource-desc","value":"class-delivery"}]"
gr_array=$param_array
echo $gr_array | sed 's/key\:/''/g' | sed 's/value\:/''/g' | sed 's/\[{/''/g' | sed 's/}\]/''/g' |  sed 's/},{/','/g' |  sed 's/\:/''/g' | sed 's/\[\]/''/g' | read gr_array

gr_arr=($(echo "$gr_array" | tr ',' '\n'))

echo "[INFO]: ARRAY Grains: $gr_arr"
echo "[INFO]: ARRAY Grains adding..."

for (( i=0; i<${#gr_arr[@]}; i=i+2 ));
do
   sed -i -e '$a\ \ '${gr_arr[$i]}':\ '${gr_arr[$i+1]}'' grains
done

# Restart Minion to apply Grain changes
echo "[INFO]: Restarting Minion Service..."
systemctl restart salt-minion
