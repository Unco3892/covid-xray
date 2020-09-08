# Identifying COVID-19 Patients by X-rays
# Ilia Azizi, Alexandre Schroeter


This repo contains all necessary files to reproduce results that can be found in our post on [Towards Data Science](XXX).

## Summary

The project focuses on identifying healthy individuals from those infected by COVID-19 (binary classification). Further, we dive deep by considering refined classes, namely, COVID-19, viral pneumonia, and bacterial pneumonia infected patients, and finally healthy individuals.

## Instructions: 

1. Clone the repo by `git clone git@github.com:Unco3892/covid-xray.git`
2. Download data files and saved models from [Google Drive](https://drive.google.com/drive/u/1/folders/12RuvBZj2lsCYb5RKMfBMnqNG1O5ZCvng) and place them in the root folder of the project

## Structure of the repo

### `report`

This folder contains the R Markdown report and its knitted version. The references are listed in `ref.bibtex`. If you would like to re-knit the report, please make sure that you have downloaded `/models` and `/data` from Google Drive.

### `scripts`
The folder structure
```
scripts/
|-  binary
|   |-  control-cloud.R 
|   |-  lenet5-trial-run.R
|   |-  train-cv.R 
|   |-  tune-confign.yml
|-  utility
|   |-  accuracy.R 
|   |-  eda.R
|   |-  generate-weights.R 
|   |-  load-data-from-directory.R
|   |-  organize-images.R
|-  depricated
|   |-  binary
|   |-   |-  densenet
|   |-   |-   |-  test_best_models_den.R
|   |-   |-   |-  train-COVID-binary.R
|   |-   |-   |-  tune-COVID-binary.R
|   |-   |-   |-  tuning_binary_dense1.R
|   |-   |-  vgg16
|   |-   |-   |-  ...
|   |-  multiclass
|   |-   |-  ...
|   |-   |-   |-  ...
```
Furthermore, the script that does this sampling has been placed [here.](https://github.com/deep-class/projg05/blob/master/scripts/import_EDA/photo-organization.R)


### `data`
The folder structure
```
data/
|-  raw
|   |-  covid-chestxray-dataset: Images of covid class last pulled on the **2nd of July, 2020** from https://github.com/ieee8023/covid-chestxray-dataset
|   |-  kermany : Images of the healthy, bacterial and viral classes extracted from https://data.mendeley.com/datasets/rscbjbr9sj/3
|-  processed
|   |-  binary
|   |-   |-  test
|   |-   |-   |-  healthy
|   |-   |-   |-  covid
|   |-   |-  test-balanced
|   |-   |-   |-  ...
|   |-   |-  train
|   |-   |-   |-  ...
|   |-  multiclass
|   |-   |-   |-  healthy
|   |-   |-   |-  covid
|   |-   |-   |-  bacterial
|   |-   |-   |-  viral
|   |-   |-  test-balanced
|   |-   |-   |-  ...
|   |-   |-  train
|   |-   |-   |-  ...
```

The `/data` used was distributed in the following way:
<center>
<table class="tg" width = 80%>
<thead>
  <tr>
    <th class="tg-i7a5"; width = 20%></th>
    <th class="tg-5x9q"; width = 10%>COVID+</th>
    <th class="tg-5x9q"; width = 10%>COVID-</th>
    <th class="tg-5x9q"; width = 10%>Viral Pneumonia</th>
    <th class="tg-5x9q"; width = 10%>Bacterial Pneumonia</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td class="tg-i7a5">Train set</td>
    <td class="tg-3zvv">161</td>
    <td class="tg-3zvv">1267</td>
    <td class="tg-3zvv">1195</td>
    <td class="tg-3zvv">2224</td>
  </tr>
  <tr>
    <td class="tg-i7a5">Balanced test set</td>
    <td class="tg-3zvv">40</td>
    <td class="tg-3zvv">40</td>
    <td class="tg-3zvv">40</td>
    <td class="tg-3zvv">40</td>
  </tr>
  <tr>
    <td class="tg-i7a5">Test set</td>
    <td class="tg-3zvv">40</td>
    <td class="tg-3zvv">316</td>
    <td class="tg-3zvv">298</td>
    <td class="tg-3zvv">556</td>
  </tr>
</tbody>
</table>
</center>
&nbsp;
&nbsp;

For balancing the classes (161 images) randomly sampling has been doing. 
  </p>
### `runs`

### `models`

### `results`

The metrics based on test datasets are stored in this folder.

### Auxiliary files: `.gitignore`, `covid-xray.Rproj`, and `README.md`

### Models and code
Transfer learning with the help of two pre-trained models has been deployed. The first model is VGG16 while the second one is the less parameterized DenseNet201. For both binary and multi-class classification, they have their own [affiliated folders](https://github.com/deep-class/projg05/blob/master/scripts) with scripts for tuning and the final re-training files. The models were tuned on the ai platform of google cloud and can be found in two subfolders and their tuning runs have been placed in the [runs folder.](https://github.com/deep-class/projg05/blob/master/runs)
The models have also been placed on the [same drive as the datasets](https://drive.google.com/drive/u/1/folders/12RuvBZj2lsCYb5RKMfBMnqNG1O5ZCvng) and the folder for the model to be placed in the same projg05 main directory.

### Report
The final report can be found in the [report folder](https://github.com/deep-class/projg05/blob/master/report) knitted to Html using the rmarkdown package. Please do note that all the testing runs can be carried out in the same folder.

