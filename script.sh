set -euo pipefail

FOO="pokemon"

echo "Here is the content"
echo "am trying to get my scripting skills right"
echo "what about this ${FOO}man"

echo
if [ ! -d "new_directory" ]; then
    mkdir new_directory
    echo "made new directory"
else
    echo "directory exists"
fi

cat <<EOF > new_directory/well_heres_the_content
echo "===== bash file ====="
well
does it work?
I really want a $FOO
EOF
cat new_directory/well_heres_the_content

 
unset FOO || true
echo 
echo testing defaults ${FOO:-baaaabaaaa}

echo

cat <<YAML > new_directory/config.yaml
echo "===== yaml file ====="
version: 1
config: 2
YAML
cat new_directory/config.yaml

ip add

# user situation