set -euo pipefail

if [ ! -d "script2" ]; then
    mkdir script2   
else
    echo
    echo "directory exists"

fi

echo
echo "hello world" | tee script2/hello.txt

cat <<EOF | tee script2/hello.txt >/dev/null
well, this the hello world script
EOF
cat script2/hello.txt


echo "i want to add this" | tee -a script2/hello.txt
echo "\ni want to add this too" | tee -a script2/hello.txt