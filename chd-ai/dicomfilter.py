import os
import pydicom
import random
import string

def take_off_tag(dicom_path):
	ds = pydicom.dcmread(dicom_path)
	ds.PatientName = ''.join(random.sample(string.ascii_letters + string.digits, 8))
	ds.PatientBirthDate = '19900000'
	ds.InstitutionName = 'wh001'
	ds.InstitutionAddress =''
	ds.StationName = 'ORTHANC'
	ds.PatientAge =''
	ds.PatientWeight =''
	ds.PatientID = str(random.randint(100000,999999))
	ds.save_as(dicom_path)

	ds = pydicom.dcmread(dicom_path)

	print 'PatientName = '+ds.PatientName
	print 'PatientBirthDate = '+ds.PatientBirthDate 
	print 'InstitutionName = '+ds.InstitutionName 
	print 'InstitutionAddress = '+ds.InstitutionAddress 
	print 'StationName = '+ds.StationName 
	print 'PatientAge = '+ds.PatientAge
	print 'PatientWeight = '+ds.PatientWeight
	print 'PatientID = '+ds.PatientID 

def rm_series(dicom_path):
	ds = pydicom.dcmread(dicom_path)
	if hasattr(ds,'SeriesDescription'):
		value = ds.SeriesDescription[-4:-2]
		if int(value) < 60:
			print value
			print path2
		
	#os.remove(path2+"/"+item)

if __name__ == '__main__':
	# dicom_path = '/Users/yangf/Desktop/-0405-0001-0001-W750L200.DCM'
	# ds = pydicom.dcmread(dicom_path)
	# print ds

	path = "/Users/apple/Desktop/files/"
	for item in os.listdir(path):
		if item == ".DS_Store":
			continue
		path2 = path+item
		for item in os.listdir(path2):
			if item == ".DS_Store":
				continue
			# path3 = path2+'/'+item
			# print path3
			# for item in os.listdir(path3):
			# 	print os.path.join(path3,item)
				print item[-3:]
			if "dcm" == item[-3:]:
				take_off_tag(path2+"/"+item)
				#os.remove(os.path.join(path2,item))
					# dicom_path = os.path.join(path3,item)
					# take_off_tag(dicom_path)
				#rm_sqe(dicom_path)
				# ds = pydicom.dcmread(dicom_path)
				# if hasattr(ds,'SeriesDescription'):
				# 	value = ds.SeriesDescription[-4:-2]
				# 	if int(value) < 60:
				# 		print value
				# 		print path2
				# 		break
				

				



