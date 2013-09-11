# make updatedb work? (or sort work with weird characters in file names)
# export NLS_LANG="AMERICAN_AMERICA.UTF8"
# export LC_ALL='C'

# OTHER DEV TOOLS 
# export MAVEN_HOME=/local/java/maven
# export JAVA_HOME=/local/java/current
# export ActiveMQ=/local/java/activemq/current

# add /usr/local/bin, google web toolkit, maven, java, activemq, mule and the current dir to path
# export PATH=$PATH:/usr/local/bin:/usr/local/gwt-mac-1.5.3:/usr/local/maven/bin:$JAVA_HOME/bin:$ActiveMQ/bin:$MAVEN_HOME/bin:~/mule/bin:.


# MAKE ORACLE WORK

if [ -d /opt/app/oracle/product/10.1.0.4/ ] ; then
	export ORACLE_HOME=/opt/app/oracle/product/10.1.0.4/
	export PATH=$ORACLE_HOME/bin:$PATH
	export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

	export CLASSPATH=/usr/local/oracle/instantclient
	export SQLPATH=/usr/local/oracle/instantclient
	export ORACLE_HOME=/usr/local/oracle/instantclient
	export PATH=$PATH:/usr/local/oracle/instantclient
	export DYLD_LIBRARY_PATH=/usr/local/oracle/instantclient

	export TNS_ADMIN=/usr/local/oracle/instantclient/tns

	# EASY ORACLE ACCESS
	alias oracletest='/usr/local/oracle/instantclient/sqlplus user/pw@server:1521/orcl'
fi
