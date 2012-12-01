part of collision_clones;

// based on http://www.siteground.com/tutorials/git/commands.htm

Map<String, String> gitMap() {
  return {
    'git config':   'Sets configuration values for your user name, email, gpg key, preferred diff algorithm, file formats and more.',
    'git init':     'Initializes a git repository – creates the initial ‘.git’ directory in a new or in an existing project.',
    'git clone':    'Makes a Git repository copy from a remote source. Also adds the original location as a remote so you can fetch from it again and push to it if you have permissions.',
    'git add':      'Adds files changes in your working directory to your index.' ,
    'git rm':       'Removes files from your index and your working directory so they will not be tracked.',
    'git commit':   'Takes all of the changes written in the index, creates a new commit object pointing to it and sets the branch to point to that new commit.',
    'git status':   'Shows you the status of files in the index versus the working directory. It will list out files that are untracked (only in your working directory), modified (tracked but not yet updated in your index), and staged (added to your index and ready for committing).',
    'git branch':   'Lists existing branches, including remote branches if ‘-a’ is provided. Creates a new branch if a branch name is provided.',
    'git checkout': 'Checks out a different branch – switches branches by updating the index, working tree, and HEAD to reflect the chosen branch.',
    'git merge':    'Merges one or more branches into your current branch and automatically creates a new commit if there are no conflicts.',
    'git reset':    'Resets your index and working directory to the state of your last commit.',
    'git stash':    'Temporarily saves changes that you don’t want to commit immediately. You can apply the changes later.',
    'git tag':      'Tags a specific commit with a simple, human readable handle that never moves.',
    'git fetch':    'Fetches all the objects from the remote repository that are not present in the local one.',
    'git pull':     'Fetches the files from the remote repository and merges it with your local one. This command is equal to the git fetch and the git merge sequence.',
    'git push':     'Pushes all the modified local objects to the remote repository and advances its branches.',
    'git remote':   'Shows all the remote versions of your repository.',
    'git log':      'Shows a listing of commits on a branch including the corresponding details.',
    'git show':     'Shows information about a git object.'
  };
}
List<String> gitList() {
  return [
    'git config',
    'git init',
    'git clone',
    'git add',
    'git rm',
    'git commit',
    'git status',
    'git branch',
    'git checkout',
    'git merge',
    'git reset',
    'git stash',
    'git tag',
    'git fetch',
    'git pull',
    'git push',
    'git remote',
    'git log',
    'git show'
  ];
}

String randomGit() => randomListElement(gitList());

String randomGitDescription() => gitMap()[randomGit()];
