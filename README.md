# Matching_FEC_Donors_by_Cycle
Program compares FEC data from different election cycles to identify donors that only contributed during one cycle or donors that contributed during all three cycles. 

The program uses Transact SQL (Microsoft SQL Server) to organize over 7gb of FEC donor data that is freely available to the public. In the program, both the table name and the candidate ID in the common table expressions have been redacted so that the user can input their own relevant information.

The program contains 4 main tests. The first test finds donors that have only donated during the 2012 cycle, while the second finds donors that have only donated during the 2014 cyclce, and the third test finds donors that have only donated during the 2016 cycle. The fourth tests finds donors that have donated during all three cycles. 

In this program common table expressions, derived tables, dynamic SQL, inner joins, and right and left joins are used. 
