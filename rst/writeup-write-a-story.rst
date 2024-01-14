.. footer::

    Copyright |copy| 2021, Harvard University CS263 |---|
    all rights reserved.

.. |copy| unicode:: 0xA9
.. |---| unicode:: U+02014

==============
Write A Story!
==============

For this project, you will write a story. More importantly, you will
set up the Docker contianer, GitHub, and Travis infrastructure
necessary for future course projects.

.. important::

    Even though the project itself is trivial, it is important that you read this **entire document** carefully, as everything here applies to future projects as well.

Git/GitHub Setup
================

Create a GitHub account if you don't already have one. Make sure your GitHub profile uses your real name so that we know who to give points to :).

Go to the `GitHub Education discount page`__ and request a free individual student account. This request should be granted almost instantaneously (check your email). Let the course staff know if there are any problems.

__ github_edu_discount_

Learn Git
---------

If you feel comfortable with git (e.g. used for a previous course or job), feel free to skip this.

Otherwise, you would benefit (both in this course and in future coursework, research, and/or jobs) by learning some git. Github offers an `interactive tutorial`__, and you can also just search for "git tutorial".

__ github_tutorial_

Docker setup
============

CS 263 is using Docker this term.  Docker allows us to provide you a consistent Linux-based environment for doing CS 263 projects with much less overhead than a conventional virtual machine.

Steps to do:

1. Set up the `CS 263 Docker image <https://github.com/harvard-cs263/cs263-docker-image>`_ by following the instructions in the README in the ``cs263-docker-image`` repo.

   1. Download and install `Docker <https://docker.com/>`_.
   2. Clone the repo.
   3. ``cd`` into ``cs263-docker-image``.
   4. Run ``./docker/cs263-build-docker``.  Make some coffee or tea
      while you wait for it to finish.
   5. Run ``./cs263-run-docker``.  Tada!

2. [Optional] Set up SSH agent on your computer: run ``ssh-add``.  This will allow your Docker image to utilize your SSH keys, allowing you to seamlessly authenticate to Github without typing your username & password.

Project Setup
=============

Click on the provided GitHub Classroom assignment link, login via GitHub if necessary, and click "Accept assignment".


Clone the Repository
--------------------

Now it is time to clone the repository.  Go to
``https://github.com/harvard-cs263/write-a-story-<YOUR-GITHUB-USERNAME>``,
copy the URL, and run in your Docker container::

    cd
    git clone <repo_url> write-a-story/

.. tip::

    This command and each subsequent Git command will ask you for your username and password, which might get annoying. If you'd like to avoid this, you might want to consider `credential helpers`__.

    Alternatively, you can clone and interact with repositories in the
    contianer using existing SSH keys on your host computer:

    - Make sure your `SSH key`__ is set up on your host computer, as well as ``ssh-agent``.
      - If ssh-based authentication isn't working, remember to run ``ssh-add``!
    - Clone the repository in the container using the URL starting
      with ``git@github.com:``.

__ github_credential_helpers_
__ ssh_setup_

Checkout & Setup
----------------

.. caution::

    For all projects, you may commit and push your changes at your leisure, as long as you **do not push to main**. If you feel you've messed up your git repository, contact the TFs for help.

All assignments come with a ``pre_setup.sh`` script. **Execute this script before starting each assignment, including this one!**

For all assignments, all of your work must committed to a non-main branch. Specifically, commits should be committed and pushed to the ``submission`` branch. You should not (and should not be able to) push commits to main.

To summarize: run the following after cloning the repository::

    cd write-a-story
    ./pre_setup.sh
    git checkout -b submission

Specification
=============

.. caution::

    For all projects, trying to modify or otherwise game the test cases will result in a grade of zero and academic dishonesty sanctions. Contact the course staff if you encounter issues with the tests.

As promised, the project itself is trivial. While you should feel free to unleash your inner Shakespeare, for this project you simply need to create a file named ``story.txt`` that is non-empty. You can "test" your "solution" by running ``make test``.

Submitting
==========

In order to submit your assignment you will need to add the new file, commit, and then push the changes to ``submission``. You should be able to do this with the following commands::

    git add story.txt
    git commit -m"commit msg"
    git push origin submission

After pushing to your branch, click the "Compare & pull request" button on your repository's GitHub page. Then, click on "Create pull request" to submit your work! The title can be whatever, and the comment can be left blank (or non-blank if you have a note for the grader).

If you need to edit your submission before the deadline, just commit and push your new changes to this branch of your repository. The original pull request will be automatically updated with those commits (of course, be sure to check the GitHub pull request page to verify).

Ensure that Travis's automatic checks on your pull request run and pass. You can find the details of a Travis build by clicking on "Details" then "The build".

.. caution::

    Do **not** click "Merge pull request" after submitting, as this will modify the main branch. We will merge your pull request when grading.

.. caution::

    The deadlines for all assignments are on Canvas. Deadlines are enforced to the minute; the last commit before the deadline will be considered the submission. The course late policy is a 10% deduction per 8 hours of lateness.

    Note that the Travis tests can take a while, and no testing-related extensions will be granted.

Deliverables and Rubric
=======================

"Automated" grading means we will assign points based on the result of the Travis test case(s).

+---------------------------------------------------+--------+----------------+
| Criteria                                          | Points | Grading method |
+===================================================+========+================+
| ``story.txt``                                     | 100    | Automated      |
+---------------------------------------------------+--------+----------------+

.. Links follow

.. _github_credential_helpers: https://help.github.com/articles/caching-your-github-password-in-git/#platform-linux
.. _github_edu_discount: https://education.github.com/discount_requests/new
.. _github_tutorial: https://try.github.io
.. _travis: https://travis-ci.com/
.. _ssh_setup: https://help.github.com/articles/connecting-to-github-with-ssh/
