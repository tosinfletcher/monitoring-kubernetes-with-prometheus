# monitoring-comic-box-app-with-prometheus

This repository uses Prometheus along with Grafana, AlertManager and Slack to monitor the Comicbox Application, Redis and other Resources deployed on Kubernetes.

Usage:


1.  Clone the repository
        
        git clone https://github.com/tosinfletcher/monitoring-kubernetes-with-prometheus.git

2.  Change into the monitoring-kubernetes-with-prometheus directory
        
        cd monitoring-kubernetes-with-prometheus
    
3.  Login into Docker Hub
        
        docker login -u <DOCKER_HUB_USERNAME>
    
5.  Use Docker to create a comicbox node image to run the comicbook application with the docker file.
        
        docker build -t <DOCKER_HUB_USERNAME>/comicbox .
    
6.  Push the docker image just created to your Docker Hub account
        
        docker push <DOCKER_HUB_USERNAME>/comicbox

7.  Go to Slack website and register for an account
          
        http://slack.com/
      
8.  Finish the basic registration setup and click the + sign beside channel to create a new channel called alerts. Then click on create. When asked to add people.         Click on skip for now.

9.  Click on the arrow down beside the alert channel -> Now click on integrations -> Click on Add an App -> Click View App Directory -> Click on Build -> Click on         Create an app -> Click on From scratch -> Name the app Prometheus -> Select the workspace you created earlier -> Click on create App -> Select Incoming Webhooks       -> Turn on -> Click on Add New Webhook to Workspace -> Select #alerts -> Click on Allow
        
10. Copy the Webhook URL into a note pad

11. Use vim to open the monitoring-kubernetes.yml file
          
        vim monitoring-kubernetes.yml
          
12. Find the slack_configs configuration under the alertmanager-conf ConfigMap and modify based 
    on your slack username, the api URL you copied to an notepad and the #alert channel you created.
        
        slack_configs:
	      - send_resolved: true
	        username: '<SLACK_USER>'
	        api_url: '<APP_URL>'
          channel: '#<CHANNEL>'

        
13. Now find the comicbox deployment configuration and modify the container image  to the one you just pushed to your Docker Hub account.
    This is to allow kubernetes pull it from your Docker Hub account when creating the application deployment later.
        
        containers:
        - name: comicbox
          image: <DOCKER_HUB_USERNAME>/comicbox
          ports:
            - containerPort: 3000

14.  Save and Quit.
        
         :wq

15. Now Create the Namespace, ConfigMap, Services and Deployments.
         
        kubectl apply -f monitoring-kubernetes.yml

16. Verify the Deployment was created successfully.
         
        kubectl get pods -n monitoring
         
        kubectl get pods
         
17. Access Prometheus from a web browser.
         
        http://<PUBLIC_IP_ADDRESS>:8080
        
18. Click on Status and then Targets to verify that all the targets are up.

19. Click on Status and then click on Rules to verigy that the rules are present

20. Click on Alert to verify that all the alert are operational

22. Access Grafana from a web browser.
         
         http://<PUBLIC_IP_ADDRESS>:8000

23. Login into Grafana (Note the below password can be changed to the one of your choice in the monitoring-kubernetes.yml file) :
         
         Username: admin
         Password: password

24. Add Prometheus as the data source for grafana.
         
         • Hover your mouse on the settings symbol and click on Data sources .
		     • Click add data source
		     • Select Prometheus
		     • Url = <PUBLIC_IP_ADDRESS>:8080
         • Access = Browser
         • Click Save & test

25. Download the kubernetes-all-nodes.json file to your local machine

26. Now add the kubernetes-all-nodes.json file to your Grafana Dashboard.
         
         • Hover you mouse on + sign and select Import. Click on Upload JSON file and select the "kubernetes-all-nodes.json" file you created earlier.
         • Click on the drop down under Promethus and Select Prometheus
         • Click on Import

27. Add the swagger-stats dashboard for prometheus in grafana.
         
         • Hover you mouse on + sign and click Import
         • type in 3091 and click on Load
         • Click on the drop down under Promethus and Select Prometheus
         • Click on Import

28. Access the ComicBox application using a web browser and generate some traffic for each page by refereshing them multiple times.
         	
          http://<PUBLIC_IP_ADDRESS>:8001
	
	        http://<PUBLIC_IP_ADDRESS>:8001/status
	
          http://<PUBLIC_IP_ADDRESS>:8001/comicbooks
          
29. Access the ComicBox swagger-stats from the web browser:
          	
          http://<PUBLIC_IP_ADDRESS>:8001/swagger-stats/ui
	
          http://<PUBLIC_IP_ADDRESS>:8001/swagger-stats/metrics

30. Verify that your Slack alert is operational.
            
            • login into your slack account and select the #alert channel
            • Use vim to open the monitoring-kubernetes.yml file
            • Scroll down to the bottom of the file and change the replicas to 0:
                  apiVersion: apps/v1
                  kind: Deployment
                  metadata:
                    name: media-redis
                  spec:
                    replicas: 0
                    selector:
                      matchLabels:
                        app: media-redis

    
31. Quit and Save.
             
             :qw   

32. Apply the change made tho the monitoring-kubernetes.yml file.
             
             kubectl apply -f monitoring-kubernetes.yml

33. Visit Prometheus on your web browser to verify that the Redis Server is firing an alert to Slack.
             
             • visit http://<PUBLIC_IP_ADDRESS>:8080
             • Click on alerts and scroll all the way down.
             • Click on RedisServerGone. The stat of the Redis Server should say FIRING

34. Go back to Slack and Click on the #alert channel you created earlier. after several minutes you would recieve the following alert.
             
             [FIRING:1] RedisServerGone (media-redis critical)
 
35. Once you recieve the alert and verified that Slack is operational, Change the number of Redis replica back to 1:
             
             • Use vim to open the monitoring-kubernetes.yml file
             • Scroll down to the bottom of the file and change the replicas to 1:
                  apiVersion: apps/v1
                  kind: Deployment
                  metadata:
                    name: media-redis
                  spec:
                    replicas: 1
                    selector:
                      matchLabels:
                        app: media-redis

36. Quit and Save.
             
             :qw 

37. Apply the change made tho the monitoring-kubernetes.yml file.
             
             kubectl apply -f monitoring-kubernetes.yml

38. Verify that the Redis Server has been re-created.
             
             kubectl get pods
             
39. Go back to the Prometheus web page to verify that the Redis Server is back and being monitored for an alert.
             
             • Click on alerts and scroll all the way down.
             • Click on RedisServerGone. It should operating normally
  
40. Go back to slack after several minutes, you should recieve another alert saying.
             
             [RESOLVED] RedisServerGone (media-redis critical)
