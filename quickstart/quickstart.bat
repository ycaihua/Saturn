@echo off
set CONSOLR_URI=http://localhost:9088
cd ..
echo [Step 1] Building Saturn, take a coffee
call mvn clean package -Dmaven.javadoc.skip=true -Dmaven.test.skip=true 

echo [Step 2] Running Saturn Console, visit %CONSOLR_URI% after a few seconds
set base_dir=%cd%
start "saturn console" java -Dfile.encoding=UTF-8 -Dsaturn.embeddedzk=true -Ddb.profiles.active=h2 -Dspring.h2.console.enabled=true -Dsaturn.stdout=true -jar saturn-console/target/saturn-console-master-SNAPSHOT-exec.jar
sleep 10

echo [Step 3] Running Saturn Executor
cd saturn-executor\target
set VIP_SATURN_ZK_CONNECTION=localhost:2181
jar xf saturn-executor-master-SNAPSHOT-zip.zip
copy %base_dir%\quickstart\demo-java-job.jar %base_dir%\saturn-executor\target\saturn-executor-master-SNAPSHOT\lib\
start "saturn executor" java -Xms256m -Xmx256m -Xss256K -Dfile.encoding=UTF-8 -Dsaturn.stdout=true -Dstart.check.outfile=status -DVIP_SATURN_CONSOLE_URI=%CONSOLR_URI% -jar saturn-executor-master-SNAPSHOT.jar  -namespace mydomain -executorName executor-1 -saturnLibDir %cd%\saturn-executor-master-SNAPSHOT -appLibDir %cd%\saturn-executor-master-SNAPSHOT\lib 
sleep 10

echo [Step 4] Add a demo java job
cd %base_dir%\saturn-executor\target\saturn-executor-master-SNAPSHOT
mkdir %base_dir%\saturn-executor\target\saturn-executor-master-SNAPSHOT\demo
copy %base_dir%\quickstart\DemoJavaJob.class  %base_dir%\saturn-executor\target\saturn-executor-master-SNAPSHOT\demo\
set LIB_JARS=lib\*;%CLASSPATH%
java -Dfile.encoding=UTF-8 -cp %LIB_JARS% demo/DemoJavaJob

echo [Step 5] Done, visit %CONSOLR_URI% for more,and you can visit %CONSOLR_URI%/h2-console to connect to the in-memory db.
@echo on

pause
