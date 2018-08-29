.. footer::

    Copyright |copy| 2017, Harvard University CS263 |---|
    all rights reserved.

.. |copy| unicode:: 0xA9
.. |---| unicode:: U+02014

==============
Write A Story!
==============

For this project, you will write a story. More importantly, you will set up the VM, GitHub, and Travis infrastructure necessary for future course projects.

.. important::

    Even though the project itself is trivial, it is important that you read this **entire document** carefully, as everything here applies to future projects as well.

GitHub Setup
============

Create a GitHub account if you don't already have one. Make sure your GitHub profile uses your real name so that we know who to give points to :).

Go to the `GitHub Education discount page`__ and request a free individual student account. This request should be granted almost instantaneously (check your email). Let the course staff know if there are any problems.

__ github_edu_discount_

Learn Git
---------

If you feel comfortable with git (e.g. used for a previous course or job), feel free to skip this.

Otherwise, you would benefit (both in this course and in future coursework, research, and/or jobs) by learning some git. Github offers an `interactive tutorial`__, and you can also just search for "git tutorial".

__ github_tutorial_

VM Setup
========

Download the CS 263 VM (``vm263.ova``) from the "Files" section of the Canvas site. Then, import the VM into a virtualization platform. We strongly recommend and only officially support VirtualBox, for which instructions are provided below. If you choose to use another platform, you are responsible for making sure the configuration is functionally equivalent to the below setup instructions.

VirtualBox Setup
----------------

This guide is for VirtualBox 5.1.22, although it will probably work for other VirtualBox versions.

- Open VirtualBox.
- Set up a host-only network:
    - In VirtualBox preferences, under "Network", go to "Host-only" and click the green add button.
    - Right-click the newly-created network (should be named something like ``vboxnet0``) and click "Edit".
    - Enter the following settings:
        - IPv4 Address: 192.168.26.1
        - IPv4 Network Mask: 255.255.255.0
        - Everything else: unchanged.
        - Make sure the DHCP Server is disabled.
    - Save these settings.
- Import the VM:
    - Click "File", then "Import Appliance".
    - Select the ``vm263.ova`` file.
    - Look over the default settings and click "Import".
- Configure networking for the VM:
    - Click on your newly-created VM and click "Settings".
    - Under "Network > Adapter 1", choose the following options:
        - Enable Network Adapter: checked
        - Attached to: Host-only Adapter
        - Name: the network you set up previously (e.g. ``vboxnet0``)
        - Promiscuous Mode (might be under "Advanced"): Allow All
        - Everything else: unchanged
    - Under "Network > Adapter 2", choose the following options:
        - Enable Network Adapter: checked
        - Attached to: NAT
        - Everything else: unchanged
    - Save these settings.

Starting and Logging Into the VM
--------------------------------

Having set up your VM, you may now start it by clicking "Start". You may choose to access it via either the VM's console or SSH. The username is ``httpd`` and the password is ``263``.

For SSH, executing ``ssh httpd@192.168.26.3`` should work.

Everything below assumes you are logged into ``httpd`` on the VM.

.. caution::

    The ``httpd`` user is part of the ``admin`` group, which has full sudo privileges. However, you should **not** run any ``apt-get`` command yet, as the first (real) project is **very** sensitive to the installed libraries. We will let you know when it is safe to use ``apt-get``.

Feel free to import your favorite dotfiles (e.g. ``.vimrc``, ``.gitconfig``, not to mention all those miscellaneous bash dotfiles).

Project Setup
=============

Click on the provided GitHub Classroom assignment link, login via GitHub if necessary, and click "Accept assignment".

By accepting the assignment, GitHub should have created a repository for you. You will do your work on a fork of the repository. On the original repository's GitHub page, click "Fork" to create this fork.

.. caution::

    It is important that you **do not** modify this original repository (the one with ``harvard-cs263`` in the URL). Only ever modify the fork. This applies to **all** projects in this course.

Travis Setup
------------

We will use Travis CI for automated testing in every course project (excluding "Buffer Overflows"). Go to Travis_ and sign in with GitHub. Click on your name in the top-right corner and click "Sync Account".

After the sync completes, you should see your fork near the bottom of the page. Click on the greyed-out slider to enable tests for the fork. Then, go to the fork's Travis settings and turn on "Auto cancel branch builds".

Clone the Fork
--------------

Now it is time to clone the fork. Go to the GitHub page for your fork (the one **without** ``harvard-cs263`` in the URL), copy the URL (make sure it begins with ``https://``), and run in your VM::

    cd
    git clone <fork_url> write-a-story/

.. tip::

    This command and each subsequent Git command will ask you for your username and password, which might get annoying. If you'd like to avoid this, you might want to consider `credential helpers`__.

    Alternatively, you can clone and interact with repositories on the VM using existing SSH keys on your host computer:

    - Make sure your `SSH key`__ is set up on your host computer, as well as ``ssh-agent``. 
    - Connect to the VM via SSH with agent forwarding enabled: ``ssh -A httpd@192.168.26.3``.
    - Clone the repository on the VM using the URL starting with ``git@github.com:``.

__ github_credential_helpers_
__ ssh_setup_

``cd`` into the repository directory to get started with the project.

Specification
=============

.. caution::

    For all projects, trying to modify or otherwise game the test cases will result in a grade of zero and academic dishonesty sanctions. Contact the course staff if you encounter issues with the tests.

.. tip::

    For all projects, you may commit and push your changes at your leisure. Each push will trigger a remote test, which you can view on the Travis_ website.

As promised, the project itself is trivial. While you should feel free to unleash your inner Shakespeare, for this project you simply need to create a file named ``story.txt`` that is non-empty. You can "test" your "solution" by running ``make test``.

Submitting
==========

.. important::

    Before submitting, make sure all your work is committed and pushed to the master branch of your fork, and make sure the Travis_ build is passing for master. You can verify by going to your fork's GitHub page, clicking on "commits", and looking for a green checkmark at the top of the list.

On the fork's GitHub page. click on "New pull request". The base fork should be the original repository (prefixed with ``harvard-cs263``), and the head fork should be your fork (prefixed with your GitHub username). Then, click on "Create pull request" to submit your work! The title can be whatever, and the comment can be left blank (or non-blank if you have a note for the grader).

If you need to edit your submission before the deadline, just commit and push your new changes to the master branch of your fork. The original pull request will be automatically updated with those commits (of course, be sure to check the GitHub pull request page to verify).

.. caution::

    Do **not** click "Merge pull request" after submitting, as this will modify the original repository. We will merge your pull request when grading.

.. caution::

    The deadlines for all assignments are on Canvas. Deadlines are enforced to the minute (based on pull request/push times, not commit times), and the course late policy is a 10% deduction per 8 hours of lateness.

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
