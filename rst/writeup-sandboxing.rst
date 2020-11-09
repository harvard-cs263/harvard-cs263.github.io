.. footer::

    Copyright |copy| 2020, Harvard University CS263 |---|
    all rights reserved.

.. |copy| unicode:: 0xA9
.. |---| unicode:: U+02014

==========
Sandboxing
==========

In this project, you'll implement a sandboxing framework. In particular, the framework will restrict the execution of a Python script that we give you. As described below, the sandboxing framework must prevent the script from executing certain system calls in certain situations. The sandboxer must also set the script's `uid` to an unprivileged one, and restrict how the script interacts with the file system.

.. note::

    This pset is new! Thus, there may be some kinks to work out :-D. The pset has four parts, with the last two being more difficult than the first two; point distribution is heavily skewed towards the easier parts. Part 1 is worth 40 points, Part 2 is worth 25 points, Part 3 is worth 15 points, and Part 4 is worth 10 points. Clean design and correctness are worth 10 points.


Project Setup
=============

- Click on the provided `GitHub Classroom assignment link`__, login via GitHub if necessary, and click "Accept assignment".
- Wait for the repository to be created.
- Login to the VM.
- ``cd ~`` to your home directory and run ``git clone <repo_url> sandboxing/`` to clone your repo.
- Run ``cd sandboxing/`` to enter the project directory.
- Run ``git checkout -b submission`` to check out a new branch. 
- Run ``./pre_setup.sh`` to download dependencies.

__ github_assignment_

Refer to Project 0's writeup for elaboration on any of these steps.

.. caution::

    Before starting, remember the warning from Project 0:

    It is important that you **do not** push to master. Push to the submission branch.

.. caution::

    For this assignment, you should use a modern Ubuntu VM. Course staff will test your submission using `Ubuntu 20`__.
__ Ubuntu_link_

Specification
=============

.. caution::

    For all projects, trying to modify or otherwise game the test cases will result in a grade of zero and academic dishonesty sanctions. Contact the course staff if you encounter issues with the tests.

.. tip::

    For all projects, you may commit and push your changes at your leisure. Commit your changes to the submission branch and push using ``git push origin submission``. Once pushed, open a Pull Request for your branch. Note that there are no Travis build tests for this pset.

PART 1: ``pid`` namespacing
---------------------------

If you look in the ``guest_dir/`` directory, you'll see a compiled Python program called ``guest.pyc``. This is the program that you need to sandbox! You should place your sandboxer in a single file called ``sandbox.c``. The program should accept two command line arguments: the path of the directory which contains ``guest.pyc`` (which should be ``guest_dir/``), and the user id whose privilege should be used to execute ``guest.pyc``. You should pass whatever (unprivileged) user id is associated with your normal login account for the VM. To see what that user id is, you can execute ``id -u <username>`` from your shell's command prompt.

.. caution::
    
    **You should launch your sandbox using root privileges. You can do so from an unprivileged shell by issuing a command like ``sudo sandbox guest_dir/ 1000``, where ``1000`` is the `uid` of the unprivileged user whose identity the guest should use.**

The first job of the sandboxer is to create a new process for the guest code to use. Your sandboxer should use the ``clone()`` system call, **not** the ``fork() system call, because ``clone()`` allows the sandboxer to place the child process in a ``pid`` namespace! Among other things, the ``pid`` namespace will restrict the set of processes that the guest can send signals to.

Your sandboxer should ``clone()`` a new process, using the ``CLONE_NEWPID`` flag to ensure that the new process is placed in a ``pid`` namespace. The child should then ``chdir()``'ing to the directory specified on the command line, call ``setuid()`` with the appropriate ``uid``, and then use ``exec()`` to execute ``python3``, passing the argument ``guest.pyc`` to ``python3.`` Meanwhile, the parent process (i.e., the sandboxer) should use a system call like ``wait()`` to wait for the child process to finish execution.

As the guest executes, it will try to do a bunch of stuff, printing output to the console. You've passed Part 1 when the guest says that it has tried and failed to access a file that only the root user should be able to access. [Note that you should not restrict the guest's activity with something like a file namespace or a ``chroot()`` jail. The guest will try to read and write files in the guest directory that was used by the pre-``exec()`` ``chdir()``; those reads and writes should succeed. The ``setuid(uid)`` call will restrict the guest's file system access to the set of files that ``uid`` can access.]


PART 2: ``pid`` namespaces
--------------------------
Now that your sandboxer knows how to ``setuid()`` restrict the guest, you should modify the sandboxer to force the guest to run in a ``pid`` namespace. Among other things, a ``pid`` namespace restricts the set of processes that can be signalled by processes within the namespace.


You've passed Part 2 when the guest says that it is correctly ``pid``-namespaced. If the guest is not correctly namespaced, then it will be able to send ``SIGKILL`` to its parent process (i.e., the sandboxer).


Submitting
==========

Push your work using ``git push origin submission``, and open a pull request from the submission branch against master.

.. important::

    Before submitting, make sure all your work is committed and pushed to the submission branch of your repository. Also make sure that you've submitted a pull request!

The title of your PR can be whatever, and the comment can be left blank (or non-blank if you have a note for the grader).

If you need to edit your submission before the deadline, just commit and push your new changes to the submission branch. The pull request will be automatically updated with those commits (of course, be sure to check the GitHub pull request page to verify).

.. caution::

    Do **not** click "Merge pull request" after submitting, as this will modify your repository. We will merge your pull request when grading.

.. caution::

    The deadlines for all assignments are on Canvas. Deadlines are enforced to the minute, and the course late policy is a 10% deduction per 8 hours of lateness.

Deliverables and Rubric
=======================

"Automated" grading means we will assign points based on whether the guest script outputs that a particular test failed or succeeded. "Manual" grading uses TF inspection of your code.

+---------------------------------------------------+--------+----------------+
| Criteria                                          | Points | Grading method |
+===================================================+========+================+
| Part 1: Guest launched with ``setuid()`` sandbox  | 40     | Automated      |
+---------------------------------------------------+--------+----------------+
| Part 2: ``pid`` namespacing                       | 25     | Automated      |
+---------------------------------------------------+--------+----------------+
| Part 3: ``fork()`` restrictions                   | 15     | Automated      |
+---------------------------------------------------+--------+----------------+
| Part 4: ``connect()`` sandboxing                  | 10     | Automated      |
+---------------------------------------------------+--------+----------------+
| Clean design and correctness                      | 10     | Manual         |
+---------------------------------------------------+--------+----------------+

.. Links follow
.. _gdb_setting_watchpoints: https://sourceware.org/gdb/current/onlinedocs/gdb/Set-Watchpoints.html#Set-Watchpoints
.. _rockyou_25k: https://harvard-cs263.github.io/resources/rockyou-top-25000.txt
.. _mozilla_firefox_debugger: https://developer.mozilla.org/en-US/docs/Tools/Debugger
.. _mozilla_pretty_print_js: https://developer.mozilla.org/en-US/docs/Tools/Debugger/How_to/Pretty-print_a_minified_file
.. _travis: https://travis-ci.com/
.. _wikipedia_minification: https://en.wikipedia.org/wiki/Minification_(programming)
.. _yolinux_libraries: http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html
.. _github_assignment: https://classroom.github.com/a/MgeggGB_
.. _Ubuntu_link: https://ubuntu.com/download/desktop