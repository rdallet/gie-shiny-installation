Install Galaxy instance (Linux)
===============================

**Requirements :**

- Python 2.7
- PostgreSQL
- uWSGI (for Galaxy v18.01)

**Packages needed :**

- git

    If not installed : `apt-get install git`

- pip

    Already installed if you're using Python 2 >=2.7.9 or Python 3 >=3.4

    If not installed : `apt-get install python-pip`

- [conda](https://conda.io/docs/user-guide/install/linux.html), to install tools


**Installation**

Start to clone the Galaxy repository :

`git clone -b release_17.09 https://github.com/galaxyproject/galaxy.git`


To start your Galaxy instance :

```
cd galaxy/
./run.sh
```

After a few minutes of installation, our galaxy instance should be running on `http://localhost:8080`


Next, make yourself an administrator.

- Create a user account using the Galaxy User Interface (Login or Register -> Register)

- Copy the provided `galaxy.ini.sample` : 

    `cp $GALAXY_PATH/config/galaxy.ini.sample $GALAXY_PATH/config/galaxy.ini`

- Modify `$GALAXY_PATH/config/galaxy.ini` to include your new user email as an admin by modifying the line `admin_users = $USER_EMAIL`

- (Re)start Galaxy (`./run.sh`)

If everything works, you should have an Admin tab on you Galaxy User Interface.
  
