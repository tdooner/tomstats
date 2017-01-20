# tomstats

A framework for downloading and analyzing statistics about my own life.

Bug bounty: Since this data is incredibly personal to me, I will give you $50 if
you are able to obtain significant data that I did not intend to publicize.
Significant data is defined as my non-fitness location history (not yet
implemented in this repo, but planned), any non-fitness Dropbox document, or any
API credential that allows write access to a connected service here.

## Installation

```bash
# 1. set up credentials
cp .env.default .env
# edit .env with the proper credentials for yourself

# 2. set up database
rake db:create db:migrate
RAILS_ENV=test rake db:create db:migrate
```
