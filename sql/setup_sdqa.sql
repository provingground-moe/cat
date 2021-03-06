-- LSST Data Management System
-- Copyright 2008, 2009, 2010 LSST Corporation.
--
-- This product includes software developed by the
-- LSST Project (http://www.lsst.org/).
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the LSST License Statement and
-- the GNU General Public License along with this program.  If not,
-- see <http://www.lsstcorp.org/LegalNotices/>.



-- Created: 24 October 2008, R. Laher (laher@ipac.caltech.edu)


DELIMITER //

-- Created: 24 October 2008, R. Laher (laher@ipac.caltech.edu)
--
-- Insert a new record into the SDQA_Threshold table.
--
-- Modifications:
--
-- 8 December 2008, R. Laher (laher@ipac.caltech.edu)
-- Removed code associated with versioning of SDQA_Threshold records,
-- since is to be handled by provenance.
--

-- Returns number of elements inserted.
-- Negative value indicates an error:
-- -1: metric not found
-- -2: insert failed
CREATE FUNCTION addSdqaThresholdRecord (
    metricName_      VARCHAR(30),
    upperThreshold_  DOUBLE,
    lowerThreshold_  DOUBLE
) RETURNS INT
  SQL SECURITY INVOKER
BEGIN

    DECLARE sdqa_thresholdId_ SMALLINT;
    DECLARE sdqa_metricId_    SMALLINT;


    -- Get sdqa_metricId.
    SELECT sdqa_metricId INTO sdqa_metricId_
    FROM   sdqa_Metric
    WHERE  metricName = metricName_;

    IF sdqa_metricId_ IS NULL THEN
        RETURN -1;
    END IF;

    -- Insert SDQA_Threshold record.
    INSERT INTO sdqa_Threshold ( sdqa_metricId,
                                 upperThreshold,
                                 lowerThreshold,
                                 createdDate )
    VALUES ( sdqa_metricId_,
             upperThreshold_,
             lowerThreshold_,
             now() );

    SELECT LAST_INSERT_ID() INTO sdqa_thresholdId_;

    IF sdqa_thresholdId_ IS NULL THEN
        RETURN -2;
    END IF;

    RETURN sdqa_thresholdId_;
END
//

DELIMITER ;

-- initialize sdqa_Metric table --

INSERT INTO sdqa_Metric (metricName, physicalUnits, dataType, definition)
VALUES ('nGoodPix', 'counts', 'f',    'Number of good pixels.')
      ,('nDeadPix', 'counts', 'f',    'Number of dead pixels.')
      ,('nHotPix' , 'counts', 'f',    'Number of hot pixels.')
      ,('nSpurPix', 'counts', 'f',    'Number of spurious pixels.')
      ,('nSatPix' , 'counts', 'f',    'Number of saturated pixels.')
      ,('nObjPix' , 'counts', 'f',    'Number of object-coverage pixels.')
      ,('nNanPix' , 'counts', 'f',    'Number of NaNed pixels.')
      ,('nDirtPix', 'counts', 'f',    'Number of pixels with filter dirt.')
      ,('nStarPix', 'counts', 'f',    'Number of star-coverage pixels.')
      ,('nGalxPix', 'counts', 'f',    'Number of galaxy-coverage pixels.')
      ,('nObjSex' , 'counts', 'f',    'Number of objects found by SExtractor.')
      ,('fwhmSex' , 'Arcsec', 't',    'SExtractor FWHM of PSF.')
      ,('gMean'   , 'D.N.'  , 't',    'Image global mean.')
      ,('gMedian' , 'D.N.'  , 't',    'Image global median.')
      ,('cMedian1', 'D.N.'  , 't',    'Image upper-left corner median.')
      ,('cMedian2', 'D.N.'  , 't',    'Image upper-right corner median.')
      ,('cMedian3', 'D.N.'  , 't',    'Image lower-right corner median.')
      ,('cMedian4', 'D.N.'  , 't',    'Image lower-left corner median.')
      ,('gMode'   , 'D.N.'  , 't',    'Image global mode.')
      ,('MmFlag'  , 'counts', 'i',    'Image global mode.')
      ,('gStdDev' , 'D.N.'  , 't',    'Image global standard deviation.')
      ,('gMAbsDev', 'D.N.'  , 't',    'Image mean absolute deviation.')
      ,('gSkewns' , 'D.N.'  , 't',    'Image skewness.')
      ,('gKurtos' , 'D.N.'  , 't',    'Image kurtosis.')
      ,('gMinVal' , 'D.N.'  , 't',    'Image minimum value.')
      ,('gMaxVal' , 'D.N.'  , 't',    'Image maximum value.')
      ,('pTile1'  , 'D.N.'  , 't',    'Image 1-percentile.')
      ,('pTile16' , 'D.N.'  , 't',    'Image 16-percentile.')
      ,('pTile84' , 'D.N.'  , 't',    'Image 84-percentile.')
      ,('pTile99' , 'D.N.'  , 't',    'Image 99-percentile.')
      ,('phot.psf.numAvailStars', 'counts', 'f',    'Number of available PSF stars.')
      ,('phot.psf.numGoodStars', 'counts', 'f',    'Number of good PSF stars.')
      ,('phot.psf.spatialFitChi2', 'dimensionless', 't',    'Chi^2 for spatial PSF fit.')
      ,('phot.psf.spatialLowOrdFlag', 'flag', 'f',    'Flag if forced to lower spatial order in PSF fit.')
      ,('ip.isr.numSaturatedPixels', 'counts', 'f',    'Number of saturated pixels.')
      ,('ip.isr.numCosmicRayPixels', 'counts', 'f',    'Number of cosmic-ray pixels.')
      ,('ip.diffim.residuals', 'sigma', 't',    'Residuals.')
      ,('ip.diffim.kernelSum', 'dimensionless', 't',    'Kernel sum.')
      ,('ip.diffim.d_residuals', 'sigma', 't',    'Per-footprint residuals.')
      ,( 'nBadCalibPix', 'counts', 'f', 'Number of pixels with compromised values (charge traps, hot pixels).' )
      ,( 'nSaturatePix', 'counts', 'f', 'Number of pixels compromised by detector saturation, including pixels with uncorrectable non-linearity.' )
      ,( 'overscanMean', 'ADU', 't', 'Mean of overscan pixels, computed from Good pixels.')
      ,( 'overscanStdDev', 'ADU', 't', 'Standard deviation of overscan pixels, computed from Good pixels.')
      ,( 'overscanMedian', 'ADU', 't', 'Median of overscan pixels, computed from Good pixels; used as robust estimate of CCD bias level.')
      ,( 'overscanMin', 'ADU', 't', 'Min of overscan pixels, computed from Good pixels.')
      ,( 'overscanMax', 'ADU', 't', 'Max of overscan pixels, computed from Good pixels.')
      ,( 'imageClipMean4Sig3Pass', 'e-', 't', 'Clipped mean of image at 4 sigma with 3 iterations, computed from Good pixels.')
      ,( 'imageSigma', 'e-', 't', 'Standard devation of image, computed from Good pixels.')
      ,( 'imageMedian', 'e-', 't', 'Median of image, computed from Good pixels.')
      ,( 'imageMin', 'e-', 't', 'Minimum of image, computed from Good pixels.')
      ,( 'imageMax', 'e-', 't', 'Maximum of image, computed from Good pixels.')
      ,( 'imageGradientX', 'e-/pixel', 't', 'Image gradient along axis 1, computed from Good pixels in background regions.')
      ,( 'imageGradientY', 'e-/pixel', 't', 'Image gradient along axis 2, computed from Good pixels in background regions.')
;



-- initialize sdqa_Threshold table --

SELECT addSdqaThresholdRecord('nGoodPix', \N   , 7500000) INTO @x;
SELECT addSdqaThresholdRecord('nDeadPix', 1000 , \N) INTO @x;
SELECT addSdqaThresholdRecord('nHotPix' , 1000 , \N) INTO @x;
SELECT addSdqaThresholdRecord('nSpurPix', 14000, \N) INTO @x;
SELECT addSdqaThresholdRecord('nSatPix' , 2500 , \N) INTO @x;
SELECT addSdqaThresholdRecord('nObjPix' , 70000, \N) INTO @x;
SELECT addSdqaThresholdRecord('nNanPix' , 1000 , \N) INTO @x;
SELECT addSdqaThresholdRecord('nDirtPix', 1000 , \N) INTO @x;
SELECT addSdqaThresholdRecord('nStarPix', \N   , 10) INTO @x;
SELECT addSdqaThresholdRecord('nGalxPix', \N   , 10) INTO @x;
SELECT addSdqaThresholdRecord('nObjSex' , \N   , 200) INTO @x;
SELECT addSdqaThresholdRecord('fwhmSex' , 6.2  , 4.4) INTO @x;
SELECT addSdqaThresholdRecord('gMean'   , 50000, 10) INTO @x;
SELECT addSdqaThresholdRecord('gMedian' , 50000, 0) INTO @x;
SELECT addSdqaThresholdRecord('cMedian1', 50000, 0) INTO @x;
SELECT addSdqaThresholdRecord('cMedian2', 50000, 0) INTO @x;
SELECT addSdqaThresholdRecord('cMedian3', 50000, 0) INTO @x;
SELECT addSdqaThresholdRecord('cMedian4', 50000, 0) INTO @x;
SELECT addSdqaThresholdRecord('gMode'   , 50000, -40) INTO @x;
SELECT addSdqaThresholdRecord('MmFlag'  , 2    , \N) INTO @x;
SELECT addSdqaThresholdRecord('gStdDev' , 1000 , 100) INTO @x;
SELECT addSdqaThresholdRecord('gMAbsDev', 50000, 10) INTO @x;
SELECT addSdqaThresholdRecord('gSkewns' , 200  , 10) INTO @x;
SELECT addSdqaThresholdRecord('gKurtos' , 50000, 10) INTO @x;
SELECT addSdqaThresholdRecord('gMinVal' , 50000, -32000) INTO @x;
SELECT addSdqaThresholdRecord('gMaxVal' , 74000, 10000) INTO @x;
SELECT addSdqaThresholdRecord('pTile1'  , 1000 , -1000) INTO @x;
SELECT addSdqaThresholdRecord('pTile16' , 20000, -100) INTO @x;
SELECT addSdqaThresholdRecord('pTile84' , 50000, 5) INTO @x;
SELECT addSdqaThresholdRecord('pTile99' , 70000, 20) INTO @x;
SELECT addSdqaThresholdRecord('phot.psf.numAvailStars', \N   , 10) INTO @x;
SELECT addSdqaThresholdRecord('phot.psf.numGoodStars', \N   , 10) INTO @x;
SELECT addSdqaThresholdRecord('phot.psf.spatialFitChi2', 3   , 0.1) INTO @x;
SELECT addSdqaThresholdRecord('phot.psf.spatialLowOrdFlag', \N   , \N) INTO @x;
SELECT addSdqaThresholdRecord('ip.isr.numSaturatedPixels', 10000, \N) INTO @x;
SELECT addSdqaThresholdRecord('ip.isr.numCosmicRayPixels', 1000, \N) INTO @x;
SELECT addSdqaThresholdRecord('ip.diffim.residuals', 0.1, -0.1) INTO @x;
SELECT addSdqaThresholdRecord('ip.diffim.kernelSum', 3, -3) INTO @x;
SELECT addSdqaThresholdRecord('ip.diffim.d_residuals', 0.1, -0.1) INTO @x;


-- initialize sdqa_ImageStatus table --

INSERT INTO sdqa_ImageStatus (statusName, definition)
VALUES
   ('passedAuto'            , 'Image passed by automated SDQA.')
  ,('marginallyPassedAuto'  , 'Image marginally passed by automated SDQA.')
  ,('marginallyFailedAuto'  , 'Image marginally failed by automated SDQA.')
  ,('failedAuto'            , 'Image failed by automated SDQA.')
  ,('indeterminateAuto'     , 'Image is indeterminate by automated SDQA.')
  ,('passedManual'          , 'Image passed by manual SDQA.')
  ,('marginallyPassedManual', 'Image marginally passed by manual SDQA.')
  ,('marginallyFailedManual', 'Image marginally failed by manual SDQA.')
  ,('failedManual'          , 'Image failed by manual SDQA.')
  ,('indeterminateManual'   , 'Image is indeterminate by manual SDQA.')
;

