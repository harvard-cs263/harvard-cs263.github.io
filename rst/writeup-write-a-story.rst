.. footer::

    Copyright |copy| 2021, Harvard University CS263 |---|
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

Download the CS 263 VM (``vm263.ova``) from the "Files" section of the Canvas site. Then, import the VM into a virtualization platform. 

VirtualBox Setup
----------------
This guide is for VirtualBox 5.1.22, although it will probably work for other VirtualBox versions.

- `Download VirtualBox <https://www.virtualbox.org/wiki/Downloads>`.
  - macOS M-chip users must instead download the `developer preview <https://www.virtualbox.org/wiki/Testbuilds>` instead, as VirtualBox does not maintain a mainline release.
- Open VirtualBox.
- Set up a host-only network:
    - In VirtualBox preferences, under "Network", go to "Host-only" and click the green add button.
    - This may also be under "File->Host Network Manager..."
    - Right-click the newly-created network (should be named something like ``vboxnet0``) and click "Edit".
    - Enter the following settings:
        - IPv4 Address: 192.168.26.1
        - IPv4 Network Mask: 255.255.255.0
        - Everything else: unchanged.
        - Make sure the DHCP Server is disabled.
    - Save these settings.
- Import the VM:
    - Click "File", then "Import Appliance".
    - Select the OVA file.
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
- Optional: set up a shared folder:
    - Under your VM, click Settings, then Shared Folders.
    - Click the "plus folder" icon.
    - Pick a folder path locally.  Perhaps a directory called ``vmshare`` in your home folder.
    - Mount it in the VM:
        - Pick ``/home/student/vmshare/`` as the mount point.
        - Check auto-mount.
    - Ensure you reboot your VM.
    - If you're getting permissions errors accessing the shared folder, run ``sudo adduser student vboxsf``.

Starting and Logging Into the VM
--------------------------------

Having set up your VM, you may now start it by clicking "Start". You may choose to access it via either the VM's console or SSH. The username is ``student`` and the password is ``student``.

For SSH, executing ``ssh student@192.168.26.3`` should work.

Everything below assumes you are logged into ``student`` on the VM.

.. caution::

    The ``student`` user is part of the ``admin`` group, which has full sudo privileges. However, you should **not** run any ``apt-get`` command yet, as the first (real) project is **very** sensitive to the installed libraries. We will let you know when it is safe to use ``apt-get``.

.. caution::
   If you're on an ARM (M-chip) macOS host, it's important to be very careful with your VM.  Your host is emulating an x86 CPU, and so all software runs with very significant overhead.  In particular, the filesystem in the Linux kernel runs much slower; if you're not careful, you can corrupt the filesystem with careless VM shutdowns.  **Always** take care to properly power-manage your VM: ``sudo systemctl poweroff`` to turn it off, ``sudo reboot`` to reboot, and use "ACPI Shutdown" from within Virtualbox.

Feel free to import your favorite dotfiles (e.g. ``.vimrc``, ``.gitconfig``, not to mention all those miscellaneous bash dotfiles).

Project Setup
=============

Click on the provided GitHub Classroom assignment link, login via GitHub if necessary, and click "Accept assignment".

.. important::

    Even though the project itself is trivial, it is important that you read this **entire document** carefully, as everything here applies to future projects as well.

Clone the Repository
--------------------

Now it is time to clone the repository.
Go to ``https://github.com/harvard-cs263/write-a-story-<YOUR-GITHUB-USERNAME>``, copy the URL (make sure it begins with ``https://``), and run in your VM::

    cd
    git clone <repo_url> write-a-story/

.. tip::

    This command and each subsequent Git command will ask you for your username and password, which might get annoying. If you'd like to avoid this, you might want to consider `credential helpers`__.

    Alternatively, you can clone and interact with repositories on the VM using existing SSH keys on your host computer:

    - Make sure your `SSH key`__ is set up on your host computer, as well as ``ssh-agent``.
    - Connect to the VM via SSH with agent forwarding enabled: ``ssh -A student@192.168.26.3``.
    - Clone the repository on the VM using the URL starting with ``git@github.com:``.

__ github_credential_helpers_
__ ssh_setup_

Checkout & Setup
----------------

.. caution::

    For all projects, you may commit and push your changes at your leisure, as long as you **do not push to master**. If you feel you've messed up your git repository contact the TFs for help.

All assignments come with a ``pre_setup.sh`` script. **Execute this script before starting each assignment, including this one!**

For all assignments, all of your work must committed to a non-master branch. Specifically, commits should be committed and pushed to the ``submission`` branch. You should not (and should not be able to) push commits to master.

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

    Do **not** click "Merge pull request" after submitting, as this will modify the master branch. We will merge your pull request when grading.

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
