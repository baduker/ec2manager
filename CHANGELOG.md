## [1.0.0] | 2021-06-10

#### Changes:
- Initial version of the service added.

## [1.1.0] | 2021-06-11

#### Changes:
- Added checks for current state; EC2 can't be stopped if it's not running, nor can it be started if it's already running.
- Fixed status output in `check_status`
- Minor style fixes
- Minor typos removed
- Improved `usage` section in `run.sh`
- Removed unnecessary tool: `gawk`

## [1.2.0] | 2021-06-21

#### Changes:
- Changed the structure of the folders
- Code refactoring: mostly prompting for user input
