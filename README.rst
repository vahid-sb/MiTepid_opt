MiTepid_opt
===========

.. image:: https://img.shields.io/badge/License-GPLv3-blue.svg
    :target: https://www.gnu.org/licenses/gpl-3.0

Introduction
------------

`MiTepid_opt`: An optimisation toolbox to estimate the parameters of compartmental epidemiological models.

The toolbox is written in Matlab uses Global Optimization Toolbox. It calculates the contact rates of a compartmental epidemiological model based on real-world data. I used it to estimate the contact rates of a model that simulates the spread of SARS-CoV-2. The estimated parameters accompany the repository (. The results of `MiTepid_opt` can and are used in `MiTepid_sim library <https://github.com/vahid-sb/MiTepid_sim>`_. The results of many runs can be already found in folder ``x0R_opt_all_vars`` and the ones exported to `MiTepid_sim` can be found in folder ``x0R_opt_MiTepid_sim``.


The toolbox provides a method to calculate the contact rates of an epidemiological model based on actual collected data on the spread of SARS-CoV-2. And it provides a method to optimise the distribution of a limited number of vaccine units in a population with a given age distribution to bring the spread of the virus as low as possible. The optimisation scheme has two constraints. One part is aimed to estimate the parameters of a set of Ordinary Differential Equations based on values of states at a given time instance, while the other part is aimed to set the spectral radius of the matrix of the contact rates to a certain value. The reasoning behind it comes from results in the theory of monotone systems and also the Perron-Frobenius Theorem. The details of the optimisation scheme as explained in the following `preprint <https://www.medrxiv.org/content/10.1101/2020.04.10.20060681v1>`_ a few months after the outbreak of SARS-CoV-2. I shared it with relevant authorities in the German government and later on I published it as an open-access paper in  `PLOS ONE <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0247439>`_. 

Running each run of the ``optimise_CR function`` takes 15-20 minutes on a cluster
which have 20 cores of type Intel(R) Xeon(R) CPU E5-2687W v4 @ 3.00GHz. And for optimise_HI function, it is around 6-7 minutes.


Installation
------------
Just download the ``mitepid_opt`` folder into your local hard disk. Add it to Matlab Paths and run ``script_Calculate_Contact_Rates.m`` or ``script_Optimise_Vaccine_Distribution.m``.

And please remember that you will need the ``Global Optimization Toolbox`` too.


Compatibility
-------------

This code is tested under Matlab 2019b but is expected to run without errors on newer versions.

Licence
-------
GNU General Public License (Version 3).


Author
-------

`MiTepid_opt` is maintained by `Vahid Samadi Bokharaie <vahid.bokharaie@protonmail.com>`_.
