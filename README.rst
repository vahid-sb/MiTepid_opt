MiTepid_sim
===========

.. image:: https://img.shields.io/pypi/v/mitepid.svg
    :target: https://pypi.python.org/pypi/mitepid
    :alt: Latest PyPI version
.. image:: https://img.shields.io/badge/License-GPLv3-blue.svg
    :target: https://www.gnu.org/licenses/gpl-3.0

Introduction
------------

`MiTepid_opt`: A package to calculate the contact rates of a compartmental epidemiological model to the real-world data of the spread of COVID-19, Made in Tübingen.

This library implements the optimisation scheme as explained in the following manuscript:
https://www.medrxiv.org/content/10.1101/2020.10.16.20213835v1

It is written in Matlab and apart from the standard Matlab functions, it also uses Global Optimization Toolbox. Details of the optimisation scheme can be found in the above-mentioend manuscript. But very briefly: provides a method to calculate the contact rates of an epidemiological model based on actual collected data on the spread of SARS-CoV-2. And it provides a methods to optimise the distribution of a limited number of vaccine units in a population with a give age-distribution to bring the spread of the virus as low as possible.

Running the each run of the ``optimise_CR funciton`` takes 15-20 minutes on a cluster
which have 20 cores of type Intel(R) Xeon(R) CPU E5-2687W v4 @ 3.00GHz. And for optimise_HI function it is around 6-7 minutes.

The results of `MiTepid_opt` can and are used in `MiTepid_sim library <https://github.com/vahid-sb/MiTepid_sim>`_.
The results of many runs can be already found in folder ``x0R_opt_all_vars`` and the ones exported to `MiTepid_sim` can be found in folder ``x0R_opt_MiTepid_sim``.


Installation
------------
Just download the ``mitepid_opt`` folder into your local hard disk. Add it to Matlab Paths and run ``script_Calculate_Contact_Rates.m`` or ``script_Optimise_Vaccine_Distribution.m``.

And please remember that you will need ``Global Optimization Toolbox`` too.


Compatibility
-------------

This code is tested under Matlab 2019b but should work well with newer versions. 

Licence
-------
GNU General Public License (Version 3).


Author
-------

`MiTepid_opt` is maintained by `Vahid Samadi Bokharaie <vahid.bokharaie@protonmail.com>`_.
