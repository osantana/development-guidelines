Processes & Practices
*********************

Guidelines for development processes and practices.


Business Orientation
====================

A developer must go beyond software development. It's required that developers
understand our business and its problems to create better solutions for it.


Guideline Enhancement Proposal
==============================

None of the guidelines in this document are immutable, but whenever a change or
improvement is required, just fill in an Enhancement Proposal at our internal
Wiki and follow the process described at GEP-0000 until approval (or
rejection).

You can use GEPs to propose technical solutions to common problems.


Code Review
===========

Code Review is a must-have discipline that improves the quality of our software
and, mainly, spread the knowledge about our platform across the team. No code
goes to production without passing the code review process.

To make a good code review we must pay attention to the following aspects:


**Be propositional in the reviews**
  It means that instead of saying "your code is poorly done, redo this", it's
  better to say "your code does not cover such and such scenarios, you probably
  will need to implement these new behaviors". Assume you got it wrong: Always
  remember that you are reviewing the code, not the human behind it. Always
  ensure you are addressing the code, not the author. If something looks strange
  or wrong, always assume **you** did not understand it and ask for
  clarification.

**Defend your arguments, but do not forget you can be wrong.**
  Whenever giant egos meet each other, it makes people disperse from main goal
  of interaction. In our case, the goal is to solve some business problem or
  opportunity with software. So to avoid unnecessary conflicts and keep the
  whole team focused on what matters, be careful when choosing your arguments'
  wording and the way you criticize others in code reviews. Practical example:
  instead of saying "this feature or code is irrelevant", it would be better to
  say "I do not understand why we're prioritizing this feature right now, could
  you explain?". It's OK to agree or disagree. We all have our own preferences
  and tastes. Look for a middle ground and remember that you own the code as
  much as the other person on your team.

**Communicate with other people, not with your computer screen.**
  This is completely basic, but especially working remote, sometimes we do not
  realize that we are talking and interacting with other people. Greeting and
  being kind can be a great way to get the reviewers' attention to your code.
  It's always good to remember that written communication is hard. Even with extra
  care, someone could misunderstand something. So, instead of assuming
  something, just ask twice before you choose not to be polite. Be human.

**Show mistakes, make suggestions but also praise good code.**
  If you see some improvement to the code you are reviewing you should make
  suggestions for improvement. If you see something wrong with code, request a
  fix. If you learn something with code or if the code shows quality and good
  practices, praise it.


Pull Requests
-------------

We use Github Pull Requests as a tool for code review.

**Make pull requests as small as possible while still delivering value.**
  Pull requests with a lot of changes usually are left behind by reviewers.
  Whenever the change involves too many files or lines, split it in smaller
  changes and open more than one pull request. You can still open several pull
  requests that are dependent on each other and work to approve one at time
  sequentially;

**Provide relevant and important information for your reviewers.**
  A reviewer needs to find all relevant and important information to review the
  code in the Pull Request description. Although we can link issues from
  bug/task systems, it's much mentally easier and inviting for the reviewer to
  find all information directly in the PR description. At the same time, do not
  over describe the PR nor be too wordy. Remember that the reviewer still needs
  to read all the code that you submit (no one told you that it would be easy);

**Try to deliver the best code possible from the very first Pull Request.**
  Sometimes the idea of submitting a PR with a code that isn't very good can be
  tempting, since it will be reviewed and you will have other chances to
  improve it. Poorly implemented or too complex code will only result in
  negative reviews and more iterations (review, request, change, submit). It
  will demand more time of the whole team, it will make the process more tiring
  and probably the final code produced will not be so good;

**Use the GitHub compare feature to get feedback instead of opening "WIP" Pull Requests.**
  It's very usual to request some pair feedback about the code you're making.
  However, you do not need to open a new Pull Request labeled "work in progress"
  to do it. Use the GitHub compare feature, in which any branch can be compared
  to the master branch. For example: if you pushed your code to a new remote
  branch called ``my-feature`` in ``foobar-api`` repository, the compare link
  would be ``https://github.com/[org]/foobar-api/compare/my-feature``.

**Work to have your Pull Request merged.**
  The developer who opened a Pull Request (the author) cannot merge it, but it
  is his responsibility to get it merged, so the author must argue in favor of
  their Pull Request with the other developers to convince them to merge it. All
  Pull Requests require at least two approvals to get merged, but at least one
  of these approvals must come from a member of another team or squad. If a
  reviewer wants to block a merge, the "Request for Changes" GitHub feature must
  be used, otherwise Pull Requests with two approvals can always be merged.

Pull Requests labels
""""""""""""""""""""

``do-not-merge``
  If your Pull Request has other PR as a dependency or the changes need to be
  deployed in a specific time, mark it with the ``do-not-merge`` label. Pull
  requests in ``do-not-merge`` still need to be reviewed, but CANNOT be merged.
  You can use this label in Pull Requests with migration code which deployment
  cannot be done immediately;

``wip``
  If one of your opened Pull Requests has a change request that will take time
  to implement, mark it as a wip so reviewers will understand that still has
  work being done. Important: use it wisely, because it's an exception, not a
  practice.

Commit Messages
---------------

Commit Messages must be written in english using the imperative mode in the
summary line::

    Fix order cancellation bug #123
    Add new publication status (sent)
    Change Order.is_active() behaviour in case of blocked status

You can read more about good commit messages in the following articles:

* https://github.com/erlang/otp/wiki/Writing-good-commit-messages
* http://chris.beams.io/posts/git-commit/


Pair Programming
================

We encourage pair programming as a practice that improves solution design,
speeds up the integration of new developers into the team, and allows more
experienced programmers to help those with less experience.

Although we encourage Pair Programming, we don't require it and won't force
anyone to do it.


Continuous Integration
======================

All code submitted to a Code Review and merged at master branch of a repository
must pass all checks and tests under our Continuous Integration environment.

Our continuous integration must run the following checks:

1. Run all automated tests;
2. Check :ref:`section-coding-style`;
3. Run linters to check the presence of credentials, debugging artifacts, etc.


Deployment
==========

.. todo::

   procedures for deployment, deployment follow-up, production readyness
   (monitor, backup, credentials, etc), checks, etc


Continuous Deployment
---------------------

.. todo::

   procedures for deployment, deployment follow-up, production
   readyness (monitor, backup, credentials, etc), checks, etc


Scheduled Maintenance
=====================

.. todo:: **TODO**

   procedures for scheduled maintenance...


Service Unavailability and Disaster Recovery
============================================

.. todo:: **TODO**

   procedures (maintenance mode on, communicate stakeholders, turn queue
   consumers off, recover data from objects history when it exists, recovery
   remaining data from backups, put services back, maintenance mode off,
   communicate)


References
==========

* `Anatomy of a Code Review <https://speakerdeck.com/asendecka/anatomy-of-a-code-review>`_
* `Yelp Code Review Guidelines <https://engineeringblog.yelp.com/2017/11/code-review-guidelines.html>`_
