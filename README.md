sep2013boot
===========

go through the github instructions to have your console git commands to work
cd to the directory you want the project folder to 

git clone https://github.com/derickson/sep2013boot.git

cd sep2013boot

git branch dev // create branch to isolate changes
git checkout dev // work in branch

// make your changes

git add *   // the files you want part of your next commit
git commit -m "Notes on changes"  // your changes
git status   // to see changes not checked in etc.

git checkout master  // to move back to master branch
git merge dev        // pull changes from dev to master


git push -u origin master  // push data back to github

git branch -d dev // when done, delete your working branch
