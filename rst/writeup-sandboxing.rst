.. footer::

    Copyright |copy| 2020, Harvard University CS263 |---|
    all rights reserved.

.. |copy| unicode:: 0xA9
.. |---| unicode:: U+02014

==========
Sandboxing
==========

In this project, you'll implement a sandboxing framework. In particular, the framework will restrict the execution of a Python script that we give you. As described below, the sandboxing framework must prevent the script from executing certain system calls in certain situations. The sandboxer must also set the script's ``uid`` to an unprivileged one, and place the script in a ``pid`` namespace.

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

    It is important that you **do not** push to main. Push to the submission branch.

.. caution::

    For this assignment, you should use a modern x86-64 Ubuntu VM. Course staff will test your submission using `Ubuntu 20`__.
__ Ubuntu_link_

Specification
=============

.. caution::

    For all projects, trying to modify or otherwise game the test cases will result in a grade of zero and academic dishonesty sanctions. Contact the course staff if you encounter issues with the tests.

.. tip::

    For all projects, you may commit and push your changes at your leisure. Commit your changes to the submission branch and push using ``git push origin submission``. Once pushed, open a Pull Request for your branch. Note that there are no Travis build tests for this pset.

PART 1: ``pid`` namespacing
---------------------------

If you look in the ``guest_dir/`` directory, you'll see a compiled Python program called ``guest.pyc``. This is the program that you need to sandbox! You should place your sandboxer in a single file called ``sandbox.c``. The program should accept two command line arguments: the path of the directory which contains ``guest.pyc`` (which should be ``guest_dir/``), and the user id whose privilege should be used to execute ``guest.pyc``. You should pass whatever (unprivileged) user id is associated with your normal login account on your VM. To see what that user id is, you can execute ``id -u <username>`` from your shell's command prompt.

.. caution::
    
    You should launch your sandboxer using root privileges. You can do so from an unprivileged shell by issuing a command like ``sudo sandbox guest_dir/ 1000``, where ``1000`` is the ``uid`` of the unprivileged user whose identity the guest should use. You must run the sandboxer as root-privileged because only root-privileged programs can create namespaces!

The first job of the sandboxer is to create a new process for the guest code to use. Your sandboxer should use the ``clone()`` system call, **not** the ``fork()`` system call, because ``clone()`` allows the sandboxer to place the child process in a ``pid`` namespace! Among other things, the ``pid`` namespace will restrict the set of processes that the guest can send signals to. So, your sandboxer should ``clone()`` a new process, using the ``CLONE_NEWPID`` flag to ensure that the new process is placed in a ``pid`` namespace. The child should then ``chdir()`` to the directory specified on the command line, and use ``exec()`` to execute ``python3``, passing the argument ``guest.pyc`` to ``python3.`` Meanwhile, the parent process (i.e., the sandboxer) should use a system call like ``wait()`` to wait for the child process to finish execution.

.. tip::

    After the sandboxer launches the initial guest process, the sandboxer should call ``sleep(1)`` before calling ``wait()``. This ensures that the OS has actually created the child process by the time that ``wait()`` is called (so that ``wait()`` won't return an error which indicates that no children are available to be waited upon).

As the guest executes, it will try to do a bunch of stuff, printing output to the console. You've passed Part 1 when the guest says that it is correctly ``pid``-namespaced. If the guest is not correctly namespaced, then it will be able to send ``SIGKILL`` to its parent process (i.e., the sandboxer).


PART 2: ``setuid()`` restrictions
---------------------------------
Now that your sandboxer knows how to ``pid``-namespace a guest, you should modify the sandboxer to force the guest to run as a non-privileged ``uid``. This is important because, right now, the guest code is ``pid``-namespaced, but still runs with ``root`` privileges! Change your sandboxer so that, after it calls ``chdir()``, but before it calls ``exec()``, it calls ``setuid()`` with the appropriate ``uid``.

You've passed Part 2 when the guest says that it has tried and failed to access a file that only the root user should be able to access.

.. caution::

    You should not restrict the guest's file activity with something like a file namespace or a ``chroot()`` jail. The guest will try to read and write files in the guest directory that was used by the pre-``exec()`` ``chdir()``; those reads and writes should succeed. The ``setuid(uid)`` call will restrict the guest's file system access to the set of files that ``uid`` can access.


PART 3: ``fork()`` restrictions
-------------------------------
The guest is now ``setuid()``-restricted and ``pid``-namespaced. However, the guest may still try to exhaust system resources, e.g., by a launching a ``fork()`` bomb. Your next task is to modify the sandboxer so that the sandboxer restricts the guest to a maximum of 3 processes. The sandboxer will need to use the `ptrace`__ API to introspect on the child's system call activity. In particular, the sandboxer needs to track the guest's process creations and process exits, tracking how many processes the guest has at any given time. The guest should have a maximum of 3 live processes at any given time; if an additional process is created, the sandboxer should kill that process **when the sandboxer observes the first system call made by that process**.

This part of the assignment is challenging; the ``ptrace`` API is complicated. You'll need to keep the ``man`` page for ``ptrace`` nearby as you work on Part 3. Here are some hints:

    - At a high-level, your sandboxer will use the ``ptrace(PTRACE_SYSCALL, <child_pid>, ...)`` call to monitor the syscall activity of guest processes. When setting up the ``ptrace()`` options, you'll need to pass the flags ``PTRACE_O_TRACECLONE | PTRACE_O_TRACEFORK  | PTRACE_O_TRACEVFORK`` to ensure that the sandboxer will see activity from the initial guest process as well as all processes spawned by that initial guest process. Note that, using ``PTRACE_SYSCALL``, the sandboxer will be awoken twice for each guest syscall: once immediately before the syscall invokes the kernel, and once immediately before the syscall returns to user mode. You will need to distinguish these two scenarios. We recommend that your sandboxer keep a table which tracks per-guest-process information; at a minimum, that table probably needs to track a guest process's ``pid`` (from the perspective of the non-``pid``-namespaced sandboxer) and whether the next expected event from the guest process is a syscall entry or a syscall return.
    - The table will also help you track how many guest processes are currently live. Note that the table must be updated when a guest process dies! The sandbox blocks for the next ``ptrace`` event by calling the `wait(int* child_status)`__ system call. The sandboxer can then use ``WIFEXITED(child_status)`` to determine if the child has died.
    - As the ``man`` page for ``ptrace`` describes, the tracer (i.e., the sandboxer) needs to handle the possibility that the tracee (i.e., a guest process) was stopped not because of a system call entry or exit, but because of a signal that was delivered to the tracee. As the ``man`` page states, "signal-delivery-stop is observed by the tracer as ``waitpid(2)`` returning with ``WIFSTOPPED(status)`` true, with the signal returned by ``WSTOPSIG(status)`` . . . [A]fter signal-delivery-stop is observed by the tracer, the tracer should restart the tracee with the call ``ptrace(PTRACE_restart, pid, 0, sig)`` where ``PTRACE_restart`` is one of the restarting ptrace requests [e.g., ``PTRACE_SYSCALL``]." So, once your sandboxer's ``wait()`` call returns, you need to check whether the traced guest process has died (if so, update your ``pid`` table), or invoked a syscall (if so, see whether the guest process needs to be killed); otherwise, if the tracee is stopped because of a signal, just replay the signal as described by the ``ptrace man`` page); or if none of that is true, just ``PTRACE_SYSCALL`` the guest process as usual to allow it to continue executing. 
    - When setting up the ``ptrace`` options, the sandboxer should also specify ``PTRACE_O_EXITKILL``, which will kill all guest processes if the sandbox dies. This ensures that, even if the guest somehow kills the sandbox, the guest processes will get killed too.
    - Before working on Part 3, it is **highly recommended** that you read `this ptrace tutorial`__! You can ignore the last section about "Foreign system emulation," but the earlier parts provide a friendly introduction to how ``ptrace`` can be used to track which system calls a traced process executes. [Note that, on Ubuntu, your sandbox includes the definition for ``struct user_regs_struct`` by including ``<sys/user.h>``.]
    - When the sandboxer needs to kill a guest process, the murder should be performed by sending the guest process the ``SIGKILL`` signal using `kill()`__. Do *not* try to use the ``PTRACE_KILL`` option for ``ptrace()``. As the ``ptrace`` ``man`` page states, ``PTRACE_KILL`` is deprecated and should not be used.
    - As you're trying to ensure that your sandboxer is seeing all of the guest processes' system calls, you may find it helpful to run the guest ``.pyc`` code using ``strace -f python3 guest.pyc`` (not using the sandboxer) to get an independent verification of what kinds of system calls the guest is executing. Remember that, on x86 Linux, a syscall invocation places the syscall number in ``%rax``; see `here`__ for a list of Linux x86-64 system calls.
    - Remember that, after your sandboxer has examined the state of a paused, non-dead guest process, the sandboxer must always restart the guest process by calling ``ptrace(PTRACE_SYSCALL, guest_pid, ...)``. If you forget to do this, the guest process will hang forever!
    - The guest processes are not multithreaded, so you can ignore the concerns in the ``ptrace man`` page about multithreaded processes.

You've passed Part 3 when the guest says that it "had the right number of children killed by the sandbox."

__ ptrace_man_page_
__ wait_man_page_
__ ptrace_tutorial_
__ kill_man_page_
__ linux_syscall_list_


PART 4: ``connect()`` restriction
---------------------------------
For the last part of the pset, you must implement selective system call blocking. In particular, you should prevent the guest from issuing ``connect()`` system calls to any TCP server unless that server has a localhost IP address ``127.0.0.*.`` See `here`__ for an overview of the system calls which a program must invoke to talk to a TCP server.

To complete this part of the pset, you'll need to perform selective syscall blocking as described by `the ptrace tutorial`__. In particular, during the entry into a syscall, the sandboxer should check whether the syscall is a ``connect()`` and if so, whether the second argument to ``connect()`` (i.e., the ``struct sockaddr_in *addr``) has a ``.sin_addr`` corresponding to ``127.0.0.*``. If so, the sandboxer should set the syscall number in ``%rax`` to ``-1``; later, when the ``connect()`` syscall tries to return to user-mode, the sandboxer should set the return value to ``-EPERM``. Here are some hints:
    - Remember that, on x86-64 Linux, a syscall invocation places the syscall number in ``%rax``. Your sandboxer should include ``<sys/syscall.h>`` to get constants for syscalls (e.g., ``SYSCALL_CONNECT``) which can be compared to the value in ``%rax`` to determine which syscall is being invoked.
    - On x86-64 Linux, syscall arguments are passed in ``%rdi``, ``%rsi``, ``%rdx``, ``%r10``, ``%r8``, and ``%r9``. For ``connect()``, the second argument is a ``struct sockaddr *addr`` (which is really a ``struct sockaddr_in``). The sandboxer must read the ``.sin_addr`` field of the ``struct`` using ``PTRACE_PEEKDATA``. Keep in mind that ``PTRACE_PEEKDATA`` reads data 8 bytes at a time. Also remember that the ``.sin_addr`` field of the ``struct sockaddr_in`` is not the first field in the ``struct``!
    - On Ubuntu, the local DNS stub resolver runs at 127.0.0.53! The guest should be able to connect to that DNS resolver. [If you want to learn more about stub resolvers, see `here`__ and `here`__.]

You've passed Part 4 when the guest says that it was "unable to fetch HTTP data from [``https://www.google.com``]: <urlopen error [Errno 1] Operation not permitted>." The guest will also try to fetch data from ``https://www.cnn.com``; the associated ``connect()`` should be denied as well. The guest will try to open a localhost TCP server on ``127.0.0.1``, and then another guest process will try to communicate with that server; the associated socket operations should be allowed. Only ``connect()`` syscalls to non-``127.0.0.*`` addresses should be blocked.

__ socket_overview_
__ ptrace_tutorial_
__ systemd_resolved_
__ dns_overview_

Submitting
==========

Push your work using ``git push origin submission``, and open a pull request from the submission branch against main.

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
| Part 1: ``pid`` namespacing                       | 40     | Automated      |
+---------------------------------------------------+--------+----------------+
| Part 2: Guest launched with ``setuid()`` sandbox  | 25     | Automated      |
+---------------------------------------------------+--------+----------------+
| Part 3: ``fork()`` restrictions                   | 15     | Automated      |
+---------------------------------------------------+--------+----------------+
| Part 4: ``connect()`` sandboxing                  | 10     | Automated      |
+---------------------------------------------------+--------+----------------+
| Clean design and correctness                      | 10     | Manual         |
+---------------------------------------------------+--------+----------------+

.. Links follow
.. _github_assignment: https://classroom.github.com/a/USuA5Ozo
.. _Ubuntu_link: https://ubuntu.com/download/desktop
.. _ptrace_man_page: https://www.man7.org/linux/man-pages/man2/ptrace.2.html
.. _kill_man_page: https://man7.org/linux/man-pages/man2/kill.2.html
.. _ptrace_tutorial: https://nullprogram.com/blog/2018/06/23/
.. _linux_syscall_list: https://filippo.io/linux-syscall-table/
.. _wait_man_page: https://man7.org/linux/man-pages/man2/wait.2.html
.. _socket_overview: https://www.cs.rpi.edu/~moorthy/Courses/os98/Pgms/socket.html
.. _systemd_resolved: http://manpages.ubuntu.com/manpages/bionic/man8/systemd-resolved.service.8.html
.. _dns_overview: https://www.internetsociety.org/resources/deploy360/dns-privacy/intro/