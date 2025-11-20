// Script to run DDL.sql and PL.sql files
// Note: DML.sql is a reference file with placeholders, not meant to be executed
const mysql = require('mysql2');
const fs = require('fs');
const path = require('path');

// Database credentials from db-connector.js
const dbConfig = {
    host: 'classmysql.engr.oregonstate.edu',
    user: 'cs340_xushi',
    password: '6570',
    database: 'cs340_xushi',
    multipleStatements: true // Allow multiple SQL statements
};

// Create connection
const connection = mysql.createConnection(dbConfig);

// Execute SQL query
function executeQuery(query, description) {
    return new Promise((resolve, reject) => {
        connection.query(query, (error, results) => {
            if (error) {
                console.error(`❌ Error: ${description}`, error.message);
                reject(error);
            } else {
                console.log(`✅ ${description}`);
                resolve(results);
            }
        });
    });
}

// Read SQL file and split by DELIMITER sections
function parseSQLFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const sections = [];
    
    // Split by DELIMITER commands
    const delimiterRegex = /DELIMITER\s+(\S+)/gi;
    let currentDelimiter = ';';
    let lastIndex = 0;
    let match;
    
    while ((match = delimiterRegex.exec(content)) !== null) {
        // Add content before this DELIMITER
        if (match.index > lastIndex) {
            const section = content.substring(lastIndex, match.index).trim();
            if (section) {
                sections.push({ sql: section, delimiter: currentDelimiter });
            }
        }
        currentDelimiter = match[1];
        lastIndex = match.index + match[0].length;
    }
    
    // Add remaining content
    if (lastIndex < content.length) {
        const section = content.substring(lastIndex).trim();
        if (section) {
            sections.push({ sql: section, delimiter: currentDelimiter });
        }
    }
    
    // If no DELIMITER found, treat entire file as one section
    if (sections.length === 0) {
        sections.push({ sql: content, delimiter: ';' });
    }
    
    return sections;
}

// Execute SQL file
async function executeSQLFile(filePath, fileName) {
    console.log(`\n📄 Processing ${fileName}...`);
    
    const sections = parseSQLFile(filePath);
    
    for (let i = 0; i < sections.length; i++) {
        const section = sections[i];
        let sql = section.sql;
        
        // Replace custom delimiter with semicolon for execution
        if (section.delimiter !== ';') {
            // Replace the delimiter at the end of statements
            sql = sql.replace(new RegExp(section.delimiter.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), ';');
        }
        
        // Remove DELIMITER commands
        sql = sql.replace(/DELIMITER\s+\S+/gi, '');
        
        // Execute if not empty
        if (sql.trim()) {
            await executeQuery(sql, `${fileName} - Section ${i + 1}`);
        }
    }
}

// Main execution
async function runSQLFiles() {
    try {
        console.log('🔌 Connecting to database...');
        console.log(`   Host: ${dbConfig.host}`);
        console.log(`   User: ${dbConfig.user}`);
        console.log(`   Database: ${dbConfig.database}`);
        
        // Test connection
        await new Promise((resolve, reject) => {
            connection.connect((err) => {
                if (err) {
                    console.error('❌ Connection failed:', err.message);
                    reject(err);
                } else {
                    console.log('✅ Connected to database successfully!\n');
                    resolve();
                }
            });
        });
        
        // Get the project root directory (parent of project folder)
        const projectRoot = path.join(__dirname, '..');
        
        // Execute SQL files in order
        // Note: DML.sql is a reference file with placeholders, not meant to be executed
        await executeSQLFile(path.join(projectRoot, 'DDL.sql'), 'DDL.sql');
        console.log('\n⏭️  Skipping DML.sql (reference file with placeholders)');
        await executeSQLFile(path.join(projectRoot, 'PL.sql'), 'PL.sql');
        
        console.log('\n✅ All SQL files executed successfully!');
        console.log('\n📊 Database setup complete!');
        console.log('   ✅ Tables created');
        console.log('   ✅ Sample data inserted');
        console.log('   ✅ Stored procedures created');
        console.log('      - reset_db()');
        console.log('      - delete_michael_chen()');
        
    } catch (error) {
        console.error('\n❌ Failed to execute SQL files:', error.message);
        process.exit(1);
    } finally {
        connection.end();
        console.log('\n🔌 Database connection closed.');
    }
}

runSQLFiles();
