# Practical-Automation-with-PowerShell
This GitHub repo contains all of the code listings and snippets for my book Practical Automation with PowerShell.

The book available for purchase at https://www.manning.com/books/practical-automation-with-powershell

Practical Automation with PowerShell: Effective scripting from the console to the cloud teaches you how to build, organize, and share useful automations with PowerShell. You’ll start with development skills you might not have learned as a sysadmin, including techniques to help you structure and manage your code, and common pitfalls to avoid. You’ll quickly progress to essential factors for sharable automations, such as securely storing information, connecting to remote machines, and creating automations that can adapt to different use cases. Finally, you’ll take your automations out into the world. You’ll learn how to share them with your team or end users, and build front ends that allow non-technical people to run them at the touch of a button.

Part 1: Getting started with automation
1. PowerShell automation
   - What you’ll learn in this book
   - Practical automation
     - Automation Goal
     - Triggers
     - Actions
     - Maintainability
   - The automation process
     - Building blocks
     - Phases
     - Combining building blocks and phases
   - Choosing the right tool for the job
     - Automation Decision Tree
     - No need to reinvent the wheel
     - Supplemental tools
   - What you need to get started today
   - Summary

2. Get started automating
   - Cleaning up old files (your first building blocks)
     - Your first function
     - Returning data from functions
     - Testing your functions
     - Problems to avoid when adding functions to scripts
     - Brevity versus efficiency
     - Careful what you automate
     - Putting it all together
   - The anatomy of PowerShell automation
     - When to add functions to a module
     - Creating a script module
     - Module creation tips
   - Summary

Part. 2: Writing scripts

3. Scheduling automation scripts
   -  Scheduled scripts
      -  Know your dependencies and take care of them beforehand
      -  Know where your script needs to execute
      -  Know what context the script needs to execute under
   -  Scheduling your scripts
      -  Task Scheduler
      -  Create scheduled task via PowerShell
      -  Cron scheduler
      -  Jenkins scheduler
   -  Watcher scripts
      -  Designing watcher scripts
      -  Invoking Action Scripts
      -  Graceful terminations
      -  Folder Watcher
      -  Action scripts
   -  Running watchers
      -  Testing Watcher Execution
      -  Scheduling Watchers
   -  Summary
4. Handling sensitive data
   -  Principles of automation security
      -  Do not store sensitive information in scripts
      -  Principle of least privilege
      -  Consider the context
      -  Create role-based service accounts
      -  Use logging and alerting
      -  Do not rely on security through obscurity
      -  Secure your scripts
   -  Credentials and secure strings in PowerShell
      -  Secure strings
      -  Credential objects
   -  Storing credentials and secure strings in PowerShell
      -  The SecretManagement module
      -  Set up the SecretStore vault
      -  Set up a KeePass vault
      -  Choosing the right vault
      -  Adding secrets to a vault
   -  Using credentials and secure strings in your automations
      -  SecretManagement module
      -  Using Jenkins credentials
   -  Know your risks
   -  Summary
5. PowerShell remote execution
   -  PowerShell remoting
      -  Remote Context
      -  Remote Protocols
      -  Persistent Sessions
   -  Script considerations for remote execution
      -  Remote execution scripts
      -  Remote execution control scripts
   -  PowerShell remoting over WS-Management (WSMan)
      -  Enable WSMan PowerShell remoting
      -  Permissions for WSMan PowerShell remoting
      -  Execute commands with WSMan PowerShell remoting
      -  Connect to the desired version of PowerShell
   -  PowerShell remoting over SSH
      -  Enable SSH PowerShell remoting
      -  Authenticating with PowerShell and SSH
      -  SSH environment considerations
      -  Execute commands with SSH PowerShell remoting
   -  Hypervisor-based remoting
   -  Agent-based remoting
   -  Setting yourself up for success with PowerShell remoting
   -  Summary
6. Making adaptable automations
   -  Event Handling
      -  Using try/catch blocks for event handling
      -  Creating custom event handles
   -  Building data-driven functions
      -  Determining your data structure
      -  Storing your data
      -  Updating your data structure
      -  Creating classes
      -  Building the function
   -  Controlling scripts with configuration data
      -  Organizing your data
      -  Using your configuration data
      -  Storing your configuration data
      -  Do not put cmdlets into your configuration data.
   -  Summary
7. Working with SQL
   -  Setting your schema
      -  Data types
   -  Connecting to SQL
      -  Permissions
   -  Adding data to a table
      -  String validation
      -  Insert data to a table
   -  Getting data from a table
      -  SQL where clause
   -  Updating records
      -  Passing pipeline data
   -  Keeping data in sync
      -  Getting server data
   -  Setting a solid foundation
   -  Summary
8. Cloud-based automation
   -  Chapter resources
   -  Setting up Azure Automation
      -  Azure Automation
      -  Log Analytics
      -  Creating Azure resources
      -  Authentication from automation runbooks
      -  Resource keys
   -  Creating a hybrid runbook worker
      -  PowerShell modules on hybrid runbook workers
   -  Creating a PowerShell runbook
      -  Automation assets
      -  Runbook editor
      -  Runbook output
      -  Interactive Cmdlets
   -  Security considerations
   -  Summary
9. Working outside of PowerShell
   -  Using COM objects and .NET Framework
      -  Importing Word objects
      -  Create a Word document
      -  Write to a Word document
      -  Adding tables to a Word document
   -  Building tables from PowerShell object
      -  Converting PowerShell objects to tables
      -  Converting PowerShell arrays to tables
   -  Getting web data
   -  Use external applications
      -  Calling an external executable
      -  Monitoring execution
      -  Getting the output
      -  Create Start-Process wrapper function
   -  utting it all together
   -  Summary
10. Automation coding best practices
    -  Defining the full automation
       -  Structuring your automation
    -  Converting a manual task to an automated one
    -  Updating structured data
    -  Using external tools
       -  Finding installed applications
       -  Call operators
    -  Defining parameters
    -  Making resumable automations
       -  Determining code logic and functions
    -  Waiting for automations
    -  Think of the next person
       -  Do not overcomplicate it
       -  Comment, comment, comment
       -  Include help and examples on all scripts and functions
       -  Have a backup plan
    -  Do not forget about the presentation
    -  Summary

Part. 3: Managing scripts

11. Sharing scripts among a team
    -  Sharing a script
       -  Creating a Gist
       -  Editing a Gist
       -  Sharing a Gist
       -  Executing a Gist
    -  Creating a shared module
       -  Uploading the module to a GitHub repository
       -  Giving access to the shared module
       -  Installing the shared module
    -  Updating a shared module
       -  Make the module self-update
       -  Creating a pull request
       -  Testing the self-update
    -  Summary
12. End-user scripts and forms
    -  Script frontends
       -  SharePoint trial tenant
    -  Creating a request form
       -  Gathering data
       -  Creating a SharePoint form
    -  Processing requests
       -  Permissions
       -  Monitoring for new requests
       -  Processing the request
    -  Running PowerShell script on end-user devices
       -  Custom Git install
       -  Running as system versus the user
       -  Using Active Setup with PowerShell
    -  Summary
13. Testing your scripts
    -  Introduction to Pester
    -  Unit testing
       -  BeforeAll
       -  Creating tests
       -  Mocks
    -  Advanced unit testing
       -  Web scraping
       -  Testing your results
       -  Mocking with parameters
       -  Unit vs. integration tests
    -  Integration testing
       -  Integration testing with external data
    -  Invoking Pester tests
    -  Summary
14. Maintaining your code
    -  Revisiting old code
    -  Automate your testing
       -  Creating a GitHub workflow
    -  Avoiding breaking changes
       -  Parameter changes
       -  Output changes
    -  Summary