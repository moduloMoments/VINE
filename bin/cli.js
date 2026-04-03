#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

const pkg = require('../package.json');
const sourceDir = path.join(__dirname, '..', 'commands', 'vine');

const args = process.argv.slice(2);
const isGlobal = args.includes('--global') || args.includes('-g');
const isHelp = args.includes('--help') || args.includes('-h');
const isVersion = args.includes('--version') || args.includes('-v');

if (isVersion) {
  console.log(`create-vine v${pkg.version}`);
  process.exit(0);
}

if (isHelp) {
  console.log(`
create-vine v${pkg.version}
Install VINE commands for Claude Code.

Usage:
  npx create-vine           Install to current project (.claude/commands/vine/)
  npx create-vine --global  Install to user-level (~/.claude/commands/vine/)

Options:
  --global, -g   Install to ~/.claude/commands/vine/ (available in all projects)
  --help, -h     Show this help message
  --version, -v  Show version number
`);
  process.exit(0);
}

const destDir = isGlobal
  ? path.join(os.homedir(), '.claude', 'commands', 'vine')
  : path.join(process.cwd(), '.claude', 'commands', 'vine');

// Count source files
const sourceFiles = fs.readdirSync(sourceDir).filter(f => f.endsWith('.md'));

// Check if this is an upgrade
const isUpgrade = fs.existsSync(destDir);

// Create destination and copy
fs.mkdirSync(destDir, { recursive: true });
for (const file of sourceFiles) {
  fs.copyFileSync(path.join(sourceDir, file), path.join(destDir, file));
}

const location = isGlobal ? '~/.claude/commands/vine/' : '.claude/commands/vine/';
const action = isUpgrade ? 'Updated' : 'Installed';
console.log(`\n  ${action} VINE v${pkg.version} to ${location} (${sourceFiles.length} commands)\n`);

if (isUpgrade) {
  console.log('  Run /vine:init to discover new tools added in this version.');
  console.log('  See CHANGELOG: https://github.com/moduloMoments/VINE/blob/main/CHANGELOG.md\n');
} else {
  console.log('  Next step: run /vine:init in Claude Code to set up project hooks.\n');
}
