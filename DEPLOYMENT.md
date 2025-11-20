# Deployment Guide
## Deploying to classwork.engr.oregonstate.edu:2016

### Prerequisites
- SSH access to `classwork.engr.oregonstate.edu`
- Your ONID credentials
- Database credentials already configured in `project/database/db-connector.js`

### Step 1: Upload Files to Server

**Option A: Using SCP (Secure Copy)**
```bash
# From your local machine, navigate to the project root
cd /Users/qwang/CS340Project_25Fall_Group20/CS340Project_25Fall_Group20

# Upload the entire project (excluding node_modules)
scp -r project DDL.sql PL.sql DML.sql your-onid@classwork.engr.oregonstate.edu:~/
```

**Option B: Using Git (Recommended)**
```bash
# On the server
ssh your-onid@classwork.engr.oregonstate.edu
cd ~
git clone <your-repo-url> CS340Project
cd CS340Project
```

### Step 2: Install Dependencies on Server

```bash
ssh your-onid@classwork.engr.oregonstate.edu
cd ~/project  # or wherever you uploaded the files
npm install
```

### Step 3: Set Up Database

Make sure your database credentials in `project/database/db-connector.js` are correct for the server environment.

Then run the SQL files:
```bash
# Option 1: Use the run-sql-files.js script
cd ~/project
node run-sql-files.js

# Option 2: Run SQL files manually via MySQL
mysql -h classmysql.engr.oregonstate.edu -u your-username -p your-database < ../DDL.sql
mysql -h classmysql.engr.oregonstate.edu -u your-username -p your-database < ../PL.sql
```

### Step 4: Start the Application

```bash
cd ~/project

# For production (runs in background with forever)
npm run production

# To stop the application
npm run stop_production

# To check if it's running
forever list
```

### Step 5: Verify Deployment

Visit: `http://classwork.engr.oregonstate.edu:2016/`

### Troubleshooting

1. **Port 2016 not accessible**: Make sure the port is open and you have permissions
2. **Database connection errors**: Verify credentials in `db-connector.js`
3. **Application not starting**: Check logs with `forever logs`
4. **Module not found errors**: Run `npm install` again

### Useful Commands

```bash
# View application logs
forever logs app.js

# Restart the application
forever restart app.js

# Stop the application
forever stop app.js

# Check if port 2016 is in use
lsof -i :2016
```

