#!/bin/bash
# Full automated deployment script
# Usage: ./deploy-full.sh your-onid

ONID=$1
SERVER="classwork.engr.oregonstate.edu"
REMOTE_DIR="~/CS340Project"

if [ -z "$ONID" ]; then
    echo "❌ Error: ONID required"
    echo "Usage: ./deploy-full.sh your-onid"
    exit 1
fi

echo "🚀 Starting deployment to $SERVER..."
echo "📦 Step 1: Uploading files..."

# Upload project files (excluding node_modules)
scp -r project DDL.sql PL.sql DML.sql $ONID@$SERVER:$REMOTE_DIR/ 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Files uploaded successfully!"
else
    echo "❌ File upload failed. Please check your SSH connection."
    exit 1
fi

echo ""
echo "📋 Step 2: Setting up on server..."
echo "   Running remote setup commands..."

# Run setup commands on remote server
ssh $ONID@$SERVER << 'ENDSSH'
cd ~/CS340Project/project
echo "📦 Installing dependencies..."
npm install
echo "✅ Dependencies installed!"
echo ""
echo "🗄️  Setting up database..."
node run-sql-files.js
echo "✅ Database setup complete!"
echo ""
echo "🚀 Starting application in production mode..."
npm run production
echo "✅ Application started!"
echo ""
echo "📊 Checking application status..."
forever list
ENDSSH

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment complete!"
    echo "🌐 Your app should be available at: http://$SERVER:2016/"
    echo ""
    echo "📝 Useful commands:"
    echo "   - View logs: ssh $ONID@$SERVER 'forever logs app.js'"
    echo "   - Stop app: ssh $ONID@$SERVER 'cd ~/CS340Project/project && npm run stop_production'"
    echo "   - Restart app: ssh $ONID@$SERVER 'cd ~/CS340Project/project && forever restart app.js'"
else
    echo "❌ Deployment failed. Please check the errors above."
    exit 1
fi

