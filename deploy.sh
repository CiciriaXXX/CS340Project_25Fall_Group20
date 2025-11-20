#!/bin/bash
# Deployment script for CS340 Project
# Usage: ./deploy.sh your-onid

ONID=$1
SERVER="classwork.engr.oregonstate.edu"
REMOTE_DIR="~/CS340Project"

if [ -z "$ONID" ]; then
    echo "Usage: ./deploy.sh your-onid"
    exit 1
fi

echo "🚀 Starting deployment to $SERVER..."
echo "📦 Uploading files..."

# Upload project files (excluding node_modules)
scp -r project DDL.sql PL.sql DML.sql $ONID@$SERVER:$REMOTE_DIR/

echo "✅ Files uploaded!"
echo ""
echo "📋 Next steps (run these on the server):"
echo "   1. ssh $ONID@$SERVER"
echo "   2. cd $REMOTE_DIR/project"
echo "   3. npm install"
echo "   4. node ../run-sql-files.js  (or run SQL files manually)"
echo "   5. npm run production"
echo ""
echo "🌐 Your app will be available at: http://$SERVER:2016/"

