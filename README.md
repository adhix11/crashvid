# Deployment of Crashvid
  * Staging
    1. ``` ssh deploy@188.166.145.19 ```
    2. ``` cd crashvid ```
    3. ``` kill `(cat tmp/pids/server.pid)`  ```
    4. ``` git pull ```
    4. ``` RAILS_ENV=staging rake db:migrate ```
    5. ``` RAILS_ENV=staging rake assets:clobber ```
    6. ``` RAILS_ENV=staging rake assets:precompile ```
    7. ``` RAILS_ENV=staging rails s -p 3000 -d ```
