# -*- coding: utf-8 -*-
"""
Created on Tue Sep 27 12:32:39 2022

 Used to import, remove any quotations within th inventory, remove any
 replicated key data, and then export as a CSV. Some of this is necessary after 
 selecting a dataset inventory on AWS Athena. Also gives size as GB as output.
 This will not work if you use versioning on AWS. A new variable will need
 to be included in the import section, and a column will need to be
 included in the export table.

@author: cioleary
"""

# Define the function. It requires an input CSV to be passed to it.
def AWSinvCleanup(inputCSV):
    #%% Import necessary modules and the CSV
    import pandas as pd
    import numpy as np
    # Import the CSV as a pandas dataframe
    inputDF = pd.read_csv(inputCSV)
    #%% Remove any "
    # These can appear due to how AWS Athena handles strings
    cleanedDF = inputDF.applymap(lambda x: x.replace('"', '')) 
    #%% Create index 
    # Find any instances of duplicated key values
    idx = cleanedDF.duplicated(subset=['key'])
    # Invert the index. This is due to the symantics of .duplicated 
    idx = np.invert(idx)
    # Reduce the DF based on the indexing
    cleanddDF = cleanedDF[idx]
    #%% If size variable exists, calculate total size of dataset, then drop variable from output CSV
    if 'size' in cleanddDF.columns:  
        size = cleanddDF['size'].astype(str).astype(int)
        sizeGB = size.sum() / (1024 ** 3)
        cleanRedDF = cleanddDF.drop(['size'], axis=1)
    else: cleanRedDF = cleanddDF
    #%% Write the new pandas dataframe to CSV
    # Give the CSV a "cleaned" name
    outputCSV = "cleaned" + inputCSV
    # Write the CSV uning the new name, without a header
    cleanRedDF.to_csv(outputCSV,header=False,index=False)
    # Give the size of the dataset in Gigabytes as an output
    print("Size in GB: " + str(sizeGB))
    return(sizeGB)
