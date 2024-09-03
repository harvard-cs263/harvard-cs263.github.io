.. footer::

    Copyright |copy| 2021, Harvard University CS263 |---|
    all rights reserved.

.. |copy| unicode:: 0xA9
.. |---| unicode:: U+02014

==============
Write A Story!
==============

For this project, you will write a story. More importantly, you will set up the VM and GitHub infrastructure necessary for future course projects.

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

Environment Setup
=================

This course requires a specific Linux environment to complete your assignments. It's crucial that you use the exact environment we provide to ensure compatibility with course materials and our grading server. We offer two options for setting up this environment:

1. Local Virtual Machine (VM) through VirtualBox
2. Amazon Web Services (AWS) EC2 Instance

If you're using an ARM-based (M-chip) macOs machine, we strongly recommend using the latter.

VM Setup
========

Download the CS 263 VM (``vm263.ova``) from `here`__. Then, import the VM into a virtualization platform. 

__ vm_ova_ 

VirtualBox Setup
----------------
Depending on the version of VirtualBox you use, the setup may vary slightly from the instructions below. At a high level, setting up your VM in VirtualBox entails importing the provided OVA file, which contains the disk image for the Linux distribution we'll be using, and then setting up the network configuration so that your VM can talk to your local machine (SSH), and the outside world (Github, Google, etc.). You can read more about the particular settings below `here`__.

- `Download VirtualBox`__.
    - macOS M-chip users must instead download the `developer preview`__, as VirtualBox does not maintain a mainline release.
- Open VirtualBox.
- Set up a host-only network:
    - In VirtualBox preferences, under "Network", go to "Host-only" and click the green add button.
    - This may also be under "File->Host Network Manager..."
    - Right-click the newly-created network (will have a default name like ``vboxnet0`` or ``HostNetwork``) and click "Edit".
    - Enter the following settings:
        - IPv4 Address: 192.168.26.1
        - IPv4 Network Mask: 255.255.255.0
        - Everything else: unchanged.
    - Save these settings.
- Import the VM:
    - Click "File", then "Import Appliance".
    - Select the OVA file.
    - Look over the default settings and click "Import".
- Configure networking for the VM:
    - Click on your newly-created VM and click "Settings".
    - Under "Network > Adapter 1", choose the following options:
        - Enable Network Adapter: checked
        - Attached to: Host-only Adapter (or Host-only Network, if Host-only Adapter is deprecated)
        - Name: the network you set up previously (e.g. ``vboxnet0`` or ``HostNetwork``)
        - Promiscuous Mode (might be under "Advanced"): Allow All
        - Everything else: unchanged
    - Under "Network > Adapter 2", choose the following options:
        - Enable Network Adapter: checked
        - Attached to: NAT
        - Everything else: unchanged
    - Save these settings.
- Optional: Set up a shared folder:
    - Under your VM, click Settings, then Shared Folders.
    - Click the "plus folder" icon.
    - Pick a folder path locally.  Perhaps a directory called ``vmshare`` in your home folder.
    - Mount it in the VM:
        - Pick ``/home/student/vmshare/`` as the mount point.
        - Check auto-mount.
    - Ensure you reboot your VM.
    - If you're getting permissions errors accessing the shared folder, run ``sudo adduser student vboxsf``.

.. tip::

    Try ``ping google.com`` to see if you can access the external network. If not:

    - List your network interfaces using ``ip link``. You should see another ethernet interface, likely named ``eth1``, whose state is down.
    - Configure your netplan YAML (located in ``etc/netplan/``) to explicitly set ``dhcp4: true`` for your second interface. You may need to use ``sudo`` to write to this file and run ``netplan apply``.


__ virtualbox_manual_
__ virtualbox_download_
__ virtualbox_mac_download_

Starting and Logging Into the VM
--------------------------------

Having set up your VM, you may now start it by clicking "Start". You may choose to access it via either the VM's console or SSH. The username is ``student`` and the password is ``student``.

To access your VM using SSH, execute ``ssh student@192.168.26.X``. The last digit of your IP address (your host address on the network) may vary; you can check the exact address inside your VM by looking at the first interface (typically named ``eth0``) in your network interface configuration (``ifconfig | less``).

.. tip::

    Password authentication for SSH may not be enabled by default. If this is the case (i.e. if you attempt to SSH fails with ``Permission denied (publickey)`` and you were not asked for a password), you can either:

    - Enable password authentication by editing the ``PasswordAuthentication`` flag in ``/etc/ssh/sshd_config`` in your VM, and then restarting the ``sshd`` service (``sudo systemctl restart sshd``), or
    - Share a public key with the VM.
        - If you already have SSH set up on your host, you can copy your existing SSH public key file (usually located in ``~/.ssh/id_rsa.pub``) into your shared folder, and then do ``cp ~/shared_folder/your_key.pub ~/.ssh/authorized_keys``
        - Or, you can `generate a new key pair`__

Everything below assumes you are logged into ``student`` on the VM.

.. caution::

    The ``student`` user is part of the ``admin`` group, which has full sudo privileges. However, you should **not** run any ``apt-get`` command yet, as the first (real) project is **very** sensitive to the installed libraries. We will let you know when it is safe to use ``apt-get``.

.. caution::
   If you're on an ARM (M-chip) macOS host, it's important to be very careful with your VM.  Your host is emulating an x86 CPU, and so all software runs with very significant overhead.  In particular, the filesystem in the Linux kernel runs much slower; if you're not careful, you can corrupt the filesystem with careless VM shutdowns.  **Always** take care to properly power-manage your VM: ``sudo systemctl poweroff`` to turn it off, ``sudo reboot`` to reboot, and use "ACPI Shutdown" from within Virtualbox.

Feel free to import your favorite dotfiles (e.g. ``.vimrc``, ``.gitconfig``, not to mention all those miscellaneous bash dotfiles).

__ ssh_key_setup_

AWS setup
=================

If you're running into problems running the VM on your laptop, follow these directions to set up the software environment in an AWS instance.

.. tip::

   We'll be taking advantage of the AWS free tier, so this should not cost you any money!

1. Account creation

   - `Create an AWS account`__.  We're using the free tier, but you will need to add a payment card.

2. Launch EC2 instance

   - Make sure you're in ``us-east-1`` (Northern Virginia).  The region selector is at the upper right of the top toolbar, next to your account name.
   - From the console dashboard, search "EC2" in the top searchbox.
   - Click "Launch Instance".
   - Use the community AMI ``ami-032c2461106e6aee3``.
   - Ensure the instance type is ``t2.micro``.
   - Under "Key pair", create a new key pair (choose ``RSA`` and ``.pem``) and save the PEM file.  (Don't lose it!  You'll need it later.)
   - Under "Network", leave "Create security group" checked, and ensure "Allow SSH traffic" is set to anywhere 0.0.0.0/0.
   - Under "Storage", use 16 GB of gp2 storage.
   - Launch!  Wait a few minutes for it to start up.

3. Connect to instance

   - ``ssh -A -i your_pem_file.PEM -L 8080:localhost:8080 student@<your EC2 instance public IPv4 DNS>``
   - For instance, ``ssh -i ~/Downloads/id_aws_va.PEM -L 8080:localhost:8080 student@ec2-ww-xxx-yyy-zzz.compute-1.amazonaws.com``

     .. tip::
        You can find your EC2 instance public IPv4 DNS by clicking "Connect to Instance" and then selecting the "SSH Client" tab. You will also need to follow the instructions there to make your ``.pem`` file private.

     .. tip::
        - The ``A`` flag enables agent forwarding, which will allow you to use your local credentials to authenticate to GitHub and clone the repository.
        - The ``L`` flag above forwards ports.  Later, once you launch the zoobar web server, you should be able to visit ``localhost:8080`` `on your laptop` and browse the webserver running on your EC2 instance.

4. Install missing software packages: The course VM comes with necessary software preinstalled.  Follow  these steps to replicate the environment in the course VM in your instance.

   - Run ``sudo dpkg --add-architecture i386``
   - Run ``sudo apt update``
   - Run ``sudo apt install --assume-yes execstack libc6-dev-i386 libssl-dev:i386 python2 python3 python-pip``
   - Run ``pip2 install sqlalchemy flask``

5. Disable ASLR: ``echo 0 | sudo tee /proc/sys/kernel/randomize_va_space``

   .. caution::
      You must re-run this if you reboot your instance!

__ aws_signup_


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

    You can clone and interact with repositories on the VM using existing SSH keys on your host computer:

    - Make sure your `SSH key`__ is set up on your host computer, as well as ``ssh-agent``.
    - Connect to the VM via SSH with agent forwarding enabled: ``ssh -A student@192.168.26.X``.
    - Clone the repository on the VM using the URL starting with ``git@github.com:``.

__ github_ssh_setup_

Checkout & Setup
----------------

.. caution::

    For all projects, you may commit and push your changes at your leisure, as long as you **do not push to master**. If you feel you've messed up your git repository contact the TFs for help.

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

.. caution::

    Do **not** click "Merge pull request" after submitting, as this will modify the main branch. We will merge your pull request when grading.

.. caution::

    The deadlines for all assignments are on Canvas. Deadlines are enforced to the minute; the last commit before the deadline will be considered the submission. The course late policy is a 10% deduction per 8 hours of lateness.

Deliverables and Rubric
=======================

"Automated" grading means we will assign points based on the result of the automated test case(s).

+---------------------------------------------------+--------+----------------+
| Criteria                                          | Points | Grading method |
+===================================================+========+================+
| ``story.txt``                                     | 100    | Automated      |
+---------------------------------------------------+--------+----------------+

.. Links follow

.. _github_edu_discount: https://education.github.com/discount_requests/new
.. _github_tutorial: https://try.github.io
.. _github_ssh_setup: https://help.github.com/articles/connecting-to-github-with-ssh/
.. _vm_ova: https://drive.google.com/file/d/1T-tfAm2Fuh5_EAPTWLzvBiYbQ3rucQ7s/view?usp=sharing
.. _virtualbox_manual: https://www.virtualbox.org/manual/ch06.html
.. _virtualbox_download: https://www.virtualbox.org/wiki/Downloads
.. _virtualbox_mac_download: https://www.virtualbox.org/wiki/Testbuilds
.. _ssh_key_setup: https://www.booleanworld.com/set-ssh-keys-linux-unix-server/
.. _aws_signup: https://portal.aws.amazon.com/billing/signup#/
