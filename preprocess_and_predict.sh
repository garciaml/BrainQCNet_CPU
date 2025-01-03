#!/bin/sh

# Example: ./preprocess_and_predict.sh /data /out_img $(VENV)/bin ${GPUID} 
# TODO: generalise to types of MRI format (NIFTY or DICOM)
# TODO: generalise to types of image format (png or jpg)

MODELTYPE="resnet152"
MODELRUN="19112020"
#MODELDIR="./saved_models/resnet152/19112020/"
MODEL="10push0.8167.pth"

hibou() {
	$3/python3 crop_nii.py -inpath $1 -outdir $2 -filename $4
}

chouette() {
	med2image --inputFile $1                                  \
                  --outputDir $3                                  \
                  --outputFileStem $2  --outputFileType png       \
                  --sliceToConvert -1                         \
	          --reslice
}

poule() {
    python predict_all_axes.py -modeldir $1 -model $2 -partid $3 -imgdir $4 -masks $5
}

mouette() {
    python transform_log_to_csv.py -indir $1 -subid $2 -method $3 -n_areas $4
    #python transform_log_to_csv.py -indir $1 -method $2 -n_areas $3
}

# Naming inputs
INPATH=$1
FILENAME=$2
SUBID=$3
OUTDIR=$4
PYTHONPATH=$5
MASKS=$6
PRED_METHOD=$7
N_AREAS=$8
MODELDIR=$9
# Activating virtual environment
. $PYTHONPATH/activate
# Cropping 3D image
hibou $INPATH . $PYTHONPATH $FILENAME
# Generating 2D slices in all 3 axes from 3D images
#mkdir -p $OUTDIR/$SUBID
chouette $FILENAME $SUBID $OUTDIR
# Removing cropped 3D image
rm ./$FILENAME
# Predicting on all the 2D slices 
poule $MODELDIR $MODEL $SUBID $OUTDIR $MASKS
mouette $OUTDIR $SUBID $PRED_METHOD $N_AREAS
# Deactivating virtual environment
deactivate
# Removing 2D slices images
rm -r $OUTDIR/x
rm -r $OUTDIR/y
rm -r $OUTDIR/z
