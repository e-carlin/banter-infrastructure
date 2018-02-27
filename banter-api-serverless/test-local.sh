rm -rf build/*
cd build
ls
cp ../.serverless/AddAccount.zip .
unzip AddAccount.zip

#sam local invoke "AddAccount" -e test.json