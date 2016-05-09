@ECHO OFF

CALL :ClearScreen

ECHO ********************** Set Template ID **********************
ECHO.
SET /P TEMPLATE_ID="Enter the template id: "
ECHO.


CALL :ClearScreen

ECHO ********************** Product Type Choices: **********************
ECHO.
ECHO 1 - DRESSWEAR
ECHO 2 - EYEWEAR
ECHO 3 - HAIRSTYLES
ECHO 4 - MASCARA
ECHO 5 - LOGO_RECOGNITION
ECHO.

ECHO Enter Product Type:
ECHO.

CHOICE /C:12345

IF ERRORLEVEL 5 (
	SET PRODUCT_TYPE=logo_recognition
) ELSE IF ERRORLEVEL 4 (
	SET PRODUCT_TYPE=mascara
) ELSE IF ERRORLEVEL 3 (
	SET PRODUCT_TYPE=hairstyles
) ELSE IF ERRORLEVEL 2 (
	SET PRODUCT_TYPE=eyewear
) ELSE IF ERRORLEVEL 1 (
	SET PRODUCT_TYPE=dresswear
)


CALL :ClearScreen

ECHO ********************** Product Environment Choices: **********************
ECHO.
ECHO 1 - DEV
ECHO 2 - DESIGN
ECHO 3 - QA
ECHO 4 - STAGE
ECHO 5 - PRESS
ECHO 6 - PROD
ECHO.

ECHO Enter Product Environment:
ECHO.

CHOICE /C:123456

IF ERRORLEVEL 6 (
	SET DESTINATION_ENVIRONMENT=prod
) ELSE IF ERRORLEVEL 5 (
	SET DESTINATION_ENVIRONMENT=press
) ELSE IF ERRORLEVEL 4 (
	SET DESTINATION_ENVIRONMENT=stage
) ELSE IF ERRORLEVEL 3 (
	SET DESTINATION_ENVIRONMENT=qa
) ELSE IF ERRORLEVEL 2 (
	SET DESTINATION_ENVIRONMENT=design
) ELSE IF ERRORLEVEL 1 (
	SET DESTINATION_ENVIRONMENT=dev
)


CALL :ClearScreen

:EnterFaceCakeVersionNumber
ECHO ********************** FaceCake App Version Number: **********************
ECHO.
SET /P FACECAKE_APP_VERSION_NUMBER="Enter the FaceCake App Version Number (i.e. 1.0.21): "
ECHO.

CALL :CheckVersionNumberFormat

CALL :ClearScreen

ECHO ********************** Banner Size Choices: **********************
ECHO.
ECHO 1 - SKYSCRAPER 300x600
ECHO 2 - EXPANDING 300x250 to 500x250
ECHO 3 - RECOMMENDATION DEMO 760x600
ECHO.

ECHO Enter Banner Size:
ECHO.

CHOICE /C:123

IF ERRORLEVEL 3 (
	SET SWF_WIDTH=768
	SET SWF_HEIGHT=600
) ELSE IF ERRORLEVEL 2 (
	SET SWF_WIDTH=500
	SET SWF_HEIGHT=250
) ELSE IF ERRORLEVEL 1 (
	SET SWF_WIDTH=300
	SET SWF_HEIGHT=600
)


CALL :ClearScreen

REM ********************** Configure For DoubleClick **********************

ECHO Do you want to enable DoubleClick for this environment?

CHOICE /C:yn

ECHO.

IF ERRORLEVEL 2 (
   SET HAS_DOUBLECLICK_TRACKING=false
) ELSE IF ERRORLEVEL 1 (
   SET HAS_DOUBLECLICK_TRACKING=true
)

IF %HAS_DOUBLECLICK_TRACKING%==true (

   ECHO Is this an expanding DoubleClick banner?
   
   CHOICE /C:yn
   
   ECHO.
   
    IF ERRORLEVEL 2 (
    
      SET IS_EXPANDING_BANNER=false
      
    ) ELSE IF ERRORLEVEL 1 (
    
      SET IS_EXPANDING_BANNER=true
      
    )
    
) ELSE (

    SET IS_EXPANDING_BANNER=false
)


CALL :ClearScreen

REM ********************** Configure For Generic Polite Load **********************

ECHO Do you want to enable a Generic Polite Load SWF for this environment?

CHOICE /C:yn

ECHO.

IF ERRORLEVEL 2 (
   SET HAS_GENERIC_POLITE_LOAD=false
) ELSE IF ERRORLEVEL 1 (
   SET HAS_GENERIC_POLITE_LOAD=true
)

IF %HAS_GENERIC_POLITE_LOAD%==true (

   ECHO Is this an expanding Generic Polite Load banner?
   
   CHOICE /C:yn
   
   ECHO.
   
    IF ERRORLEVEL 2 (
    
      SET IS_EXPANDING_GENERIC_POLITE_LOAD_BANNER=false
      
    ) ELSE IF ERRORLEVEL 1 (
    
      SET IS_EXPANDING_GENERIC_POLITE_LOAD_BANNER=true
      
    )
    
) ELSE (

    SET IS_EXPANDING_GENERIC_POLITE_LOAD_BANNER=false
)


CALL :ClearScreen

REM ********************** Confirm Deployment **********************

ECHO Are you sure you want to deploy the %PRODUCT_TYPE% %TEMPLATE_ID% banner to the %DESTINATION_ENVIRONMENT% environment?

CHOICE /C:yn

ECHO.

IF ERRORLEVEL 2 (
	exit
)


REM ********************** Set DoubleClick Swf Filename **********************

SET DOUBLECLICK_FILENAME=doubleClickParent_%DESTINATION_ENVIRONMENT%_%TEMPLATE_ID%_cache.swf


REM ********************** Set TryOn Swf Filename **********************

SET TRYON_FILENAME=tryOn_%DESTINATION_ENVIRONMENT%_%TEMPLATE_ID%_cache.swf


REM ********************** Set Animation A Swf Filename **********************

SET TRYON_VIEW_ANIMATION_A_FILENAME=tryOnViewForPoliteLoadExpandingBannerA_%DESTINATION_ENVIRONMENT%_%TEMPLATE_ID%_cache.swf


REM ********************** Set Animation B Swf Filename **********************

SET TRYON_VIEW_ANIMATION_B_FILENAME=tryOnViewForPoliteLoadExpandingBannerB_%DESTINATION_ENVIRONMENT%_%TEMPLATE_ID%_cache.swf


REM ********************** Set Eyeblaster Polite Load Animation Filename **********************

SET EYEBLASTER_ANIMATION_FOR_POLITE_LOAD_SKYSCRAPER_FILENAME=eyeBlasterAnimationForPoliteLoadSkyscraper_%DESTINATION_ENVIRONMENT%_%TEMPLATE_ID%_cache.swf


REM ********************** Set Product Name **********************

SET PRODUCT_NAME=tob


REM ********************** Set Dynamic Paths **********************

SET SOURCE_DRIVE=%~d0\

SET BATCH_PATH=%CD%

CD..

SET WEB_APP_PATH=%CD%

CD %WEB_APP_PATH%\batch

SET SOURCE_PATH=%WEB_APP_PATH%\templates

SET SOURCE_BIN_DEBUG_PATH=%SOURCE_PATH%\%PRODUCT_TYPE%\%TEMPLATE_ID%\bin-debug

SET SOURCE_COMMON_BIN_DEBUG_PATH=%WEB_APP_PATH%\bin-debug

SET DESTINATION_DRIVE=V:

SET DESTINATION_DOMAIN=\facecake.com\media

SET DESTINATION_PATH=%DESTINATION_DRIVE%%DESTINATION_DOMAIN%\%DESTINATION_ENVIRONMENT%\%PRODUCT_NAME%\%TEMPLATE_ID%

SET SOURCE_AMFPHP_PATH=%WEB_APP_PATH%\templates\%PRODUCT_TYPE%\_all\amfphp

SET DESTINATION_AMFPHP_PATH=%DESTINATION_DRIVE%\%DESTINATION_DOMAIN%\%DESTINATION_ENVIRONMENT%\%PRODUCT_NAME%\%TEMPLATE_ID%\amfphp

SET SOURCE_LEGAL_PATH=%WEB_APP_PATH%\content\html

SET DESTINATION_LEGAL_PATH=%DESTINATION_DRIVE%%DESTINATION_DOMAIN%\%DESTINATION_ENVIRONMENT%\%PRODUCT_NAME%


REM ********************** Create Face Detection and Object Detection Source and Destination Paths **********************

CD..

CD..

CD..

CD..

CD..

SET PROJECTS_PATH=%CD%


CD %PROJECTS_PATH%\face_detection_flash

SET FACE_DETECTION_PROJECT_PATH=%CD%

CD %FACE_DETECTION_PROJECT_PATH%\trunk\desktop\WpfApplication1\bin\Release

SET SOURCE_FACE_DETECTION_EXE_PATH=%CD%


CD %PROJECTS_PATH%\object_detection_flash

SET OBJECT_DETECTION_PROJECT_PATH=%CD%

CD %OBJECT_DETECTION_PROJECT_PATH%\trunk\ObjectDetectionFlash\bin\Release

SET SOURCE_OBJECT_DETECTION_EXE_PATH=%CD%



CALL :ClearScreen

REM ********************** Copy Files To Server **********************

ECHO Creating folders on %DESTINATION_ENVIRONMENT% server...

ECHO.

if not exist %DESTINATION_PATH% mkdir %DESTINATION_PATH% >nul 2>&1
if not exist %DESTINATION_PATH%\img mkdir %DESTINATION_PATH%\img >nul 2>&1
if not exist %DESTINATION_PATH%\img\email mkdir %DESTINATION_PATH%\img\email >nul 2>&1
if not exist %DESTINATION_PATH%\xml mkdir %DESTINATION_PATH%\xml >nul 2>&1
if not exist %DESTINATION_PATH%\users mkdir %DESTINATION_PATH%\users >nul 2>&1

if not exist %DESTINATION_PATH%\images mkdir %DESTINATION_PATH%\images >nul 2>&1
if not exist %DESTINATION_PATH%\images\banner mkdir %DESTINATION_PATH%\images\banner >nul 2>&1
if not exist %DESTINATION_PATH%\css mkdir %DESTINATION_PATH%\css >nul 2>&1
if not exist %DESTINATION_PATH%\css\fonts mkdir %DESTINATION_PATH%\css\fonts >nul 2>&1
if not exist %DESTINATION_PATH%\js mkdir %DESTINATION_PATH%\js >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp mkdir %DESTINATION_PATH%\amfphp >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\browser mkdir %DESTINATION_PATH%\amfphp\browser >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core mkdir %DESTINATION_PATH%\amfphp\core >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\amf mkdir %DESTINATION_PATH%\amfphp\core\amf >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\amf\app mkdir %DESTINATION_PATH%\amfphp\core\amf\app >nul 2>&1
if not exist %DESTINATION_PATH%\amfphp\core\amf\io mkdir %DESTINATION_PATH%\amfphp\core\amf\io >nul 2>&1
if not exist %DESTINATION_PATH%\amfphp\core\amf\util mkdir %DESTINATION_PATH%\amfphp\core\amf\util >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\json mkdir %DESTINATION_PATH%\amfphp\core\json >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\json\app mkdir %DESTINATION_PATH%\amfphp\core\json\app >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\shared mkdir %DESTINATION_PATH%\amfphp\core\shared >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\shared\adapters mkdir %DESTINATION_PATH%\amfphp\core\shared\adapters >nul 2>&1
if not exist %DESTINATION_PATH%\amfphp\core\shared\app mkdir %DESTINATION_PATH%\amfphp\core\shared\app >nul 2>&1
if not exist %DESTINATION_PATH%\amfphp\core\shared\exception mkdir %DESTINATION_PATH%\amfphp\core\shared\exception >nul 2>&1
if not exist %DESTINATION_PATH%\amfphp\core\shared\util mkdir %DESTINATION_PATH%\amfphp\core\shared\util >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\xmlrpc mkdir %DESTINATION_PATH%\amfphp\core\xmlrpc >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\core\xmlrpc\app mkdir %DESTINATION_PATH%\amfphp\core\xmlrpc\app >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\services mkdir %DESTINATION_PATH%\amfphp\services >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\services\Swift mkdir %DESTINATION_PATH%\amfphp\services\Swift >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\services\Swift\Authenticator mkdir %DESTINATION_PATH%\amfphp\services\Swift\Authenticator >nul 2>&1
if not exist %DESTINATION_PATH%\amfphp\services\Swift\Connection mkdir %DESTINATION_PATH%\amfphp\services\Swift\Connection >nul 2>&1
if not exist %DESTINATION_PATH%\amfphp\services\Swift\Plugin mkdir %DESTINATION_PATH%\amfphp\services\Swift\Plugin >nul 2>&1

if not exist %DESTINATION_PATH%\amfphp\services\amfphp mkdir %DESTINATION_PATH%\amfphp\services\amfphp >nul 2>&1

IF %PRODUCT_TYPE%==logo_recognition (
	if not exist %DESTINATION_PATH%\amfphp\services\Images mkdir %DESTINATION_PATH%\amfphp\services\Images >nul 2>&1
	if not exist %DESTINATION_PATH%\amfphp\services\Images\Object mkdir %DESTINATION_PATH%\amfphp\services\Images\Object >nul 2>&1
)

ECHO Deleting existing files on %DESTINATION_ENVIRONMENT% server...

ECHO.

del %DESTINATION_PATH%\*.html /Q >nul 2>&1
del %DESTINATION_PATH%\*.swf /Q >nul 2>&1
del %DESTINATION_PATH%\*.php /Q >nul 2>&1
del %DESTINATION_PATH%\*.jpg /Q >nul 2>&1
del %DESTINATION_PATH%\img\*.png /Q >nul 2>&1
del %DESTINATION_PATH%\img\email\*.jpg /Q >nul 2>&1
del %DESTINATION_PATH%\xml\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\users\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\images\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\images\banners\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\css\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\css\fonts\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\js\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\browser\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\core\amf\app\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\core\amf\io\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\core\amf\util\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\core\json\app\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\core\shared\adapters\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\core\shared\app\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\core\shared\exception\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\core\shared\util\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\core\xmlrpc\app\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\services\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\services\Swift\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\services\Swift\Authenticator\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\services\Swift\Connection\*.* /Q >nul 2>&1
del %DESTINATION_PATH%\amfphp\services\Swift\Plugin\*.* /Q >nul 2>&1

del %DESTINATION_PATH%\amfphp\services\amfphp\*.* /Q >nul 2>&1

del %DESTINATION_LEGAL_PATH%\privacy_policy.html /Q >nul 2>&1
del %DESTINATION_LEGAL_PATH%\terms_of_use.html /Q >nul 2>&1

IF %PRODUCT_TYPE%==eyewear (
	del %DESTINATION_PATH%\amfphp\services\Images\Object\*.* /Q >nul 2>&1
)

IF %PRODUCT_TYPE%==mascara (
	del %DESTINATION_PATH%\amfphp\services\Images\Object\*.* /Q >nul 2>&1
)

IF %PRODUCT_TYPE%==hairstyles (
	del %DESTINATION_PATH%\amfphp\services\Images\Object\*.* /Q >nul 2>&1
)

IF %PRODUCT_TYPE%==logo_recognition (
	del %DESTINATION_PATH%\amfphp\services\Images\Object\*.* /Q >nul 2>&1
)

ECHO Copying files to %DESTINATION_ENVIRONMENT% server...

ECHO.

if exist %SOURCE_BIN_DEBUG_PATH%\doubleClickParent.swf xcopy %SOURCE_BIN_DEBUG_PATH%\doubleClickParent.swf %DESTINATION_PATH% /Y >nul
if exist %SOURCE_BIN_DEBUG_PATH%\doubleClickChild.swf xcopy %SOURCE_BIN_DEBUG_PATH%\doubleClickChild.swf %DESTINATION_PATH% /Y >nul
if exist %SOURCE_BIN_DEBUG_PATH%\doubleClickChildCollapsed.swf xcopy %SOURCE_BIN_DEBUG_PATH%\doubleClickChildCollapsed.swf %DESTINATION_PATH% /Y >nul
if exist %SOURCE_BIN_DEBUG_PATH%\doubleClickChildExpanded.swf xcopy %SOURCE_BIN_DEBUG_PATH%\doubleClickChildExpanded.swf %DESTINATION_PATH% /Y >nul
if exist %SOURCE_BIN_DEBUG_PATH%\tryOnViewBackgroundAnimation.swf xcopy %SOURCE_BIN_DEBUG_PATH%\tryOnViewBackgroundAnimation.swf %DESTINATION_PATH% /Y >nul
if exist %SOURCE_BIN_DEBUG_PATH%\backup.jpg xcopy %SOURCE_BIN_DEBUG_PATH%\backup.jpg %DESTINATION_PATH% /Y >nul

xcopy %SOURCE_BIN_DEBUG_PATH%\*.* %DESTINATION_PATH% /E /Y >nul

xcopy %SOURCE_COMMON_BIN_DEBUG_PATH%\*.* %DESTINATION_PATH% /E /Y >nul

xcopy %SOURCE_AMFPHP_PATH%\*.* %DESTINATION_AMFPHP_PATH% /E /Y >nul

xcopy %SOURCE_LEGAL_PATH%\privacy_policy.html %DESTINATION_LEGAL_PATH%\ /Y >nul
xcopy %SOURCE_LEGAL_PATH%\terms_of_use.html %DESTINATION_LEGAL_PATH%\ /Y >nul

IF %PRODUCT_TYPE%==eyewear (
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\fd.exe %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\*.dll %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
)

IF %PRODUCT_TYPE%==mascara (
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\fd.exe %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\*.dll %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
)

IF %PRODUCT_TYPE%==hairstyles (
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\fd.exe %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\*.dll %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
)

IF %PRODUCT_TYPE%==logo_recognition (
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\fd.exe %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
	xcopy %SOURCE_FACE_DETECTION_EXE_PATH%\*.dll %DESTINATION_AMFPHP_PATH%\services /E /Y >nul

	xcopy %SOURCE_OBJECT_DETECTION_EXE_PATH%\ObjectDetectionFlash.exe %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
	xcopy %SOURCE_OBJECT_DETECTION_EXE_PATH%\FaceCake.OpenCV.dll %DESTINATION_AMFPHP_PATH%\services /E /Y >nul
)

REM ********************** Rename Files **********************

ECHO Renaming Files...

ECHO.

rename %DESTINATION_PATH%\tryOn.swf %TRYON_FILENAME%

if exist %DESTINATION_PATH%\doubleClickParent.swf rename %DESTINATION_PATH%\doubleClickParent.swf %DOUBLECLICK_FILENAME%

if exist %DESTINATION_PATH%\tryOnViewForPoliteLoadExpandingBannerA.swf rename %DESTINATION_PATH%\tryOnViewForPoliteLoadExpandingBannerA.swf %TRYON_VIEW_ANIMATION_A_FILENAME%

if exist %DESTINATION_PATH%\tryOnViewForPoliteLoadExpandingBannerB.swf rename %DESTINATION_PATH%\tryOnViewForPoliteLoadExpandingBannerB.swf %TRYON_VIEW_ANIMATION_B_FILENAME%

if exist %DESTINATION_PATH%\eyeBlasterAnimationForPoliteLoadSkyscraper.swf rename %DESTINATION_PATH%\eyeBlasterAnimationForPoliteLoadSkyscraper.swf %EYEBLASTER_ANIMATION_FOR_POLITE_LOAD_SKYSCRAPER_FILENAME%


REM ********************** Customize index.html **********************

ECHO Customizing index.html...

ECHO.

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_ENVIRONMENT_NAME_HERE" %DESTINATION_ENVIRONMENT% %DESTINATION_PATH%\index.html>%DESTINATION_PATH%\index2.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_TEMPLATE_ID_HERE" %TEMPLATE_ID% %DESTINATION_PATH%\index2.html>%DESTINATION_PATH%\index3.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_FACECAKE_APP_VERSION_NUMBER_HERE" %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_PATH%\index3.html>%DESTINATION_PATH%\index4.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_WIDTH_HERE" %SWF_WIDTH% %DESTINATION_PATH%\index4.html>%DESTINATION_PATH%\index5.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_HEIGHT_HERE" %SWF_HEIGHT% %DESTINATION_PATH%\index5.html>%DESTINATION_PATH%\index6.html

del %DESTINATION_PATH%\index.html >nul 2>&1
del %DESTINATION_PATH%\index2.html >nul 2>&1
del %DESTINATION_PATH%\index3.html >nul 2>&1
del %DESTINATION_PATH%\index4.html >nul 2>&1
del %DESTINATION_PATH%\index5.html >nul 2>&1

rename %DESTINATION_PATH%\index6.html index.html


REM ********************** Customize index_polite.html **********************

ECHO Customizing index_polite.html...

ECHO.

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_ENVIRONMENT_NAME_HERE" %DESTINATION_ENVIRONMENT% %DESTINATION_PATH%\index_polite.html>%DESTINATION_PATH%\index_polite2.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_TEMPLATE_ID_HERE" %TEMPLATE_ID% %DESTINATION_PATH%\index_polite2.html>%DESTINATION_PATH%\index_polite3.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_FACECAKE_APP_VERSION_NUMBER_HERE" %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_PATH%\index_polite3.html>%DESTINATION_PATH%\index_polite4.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_WIDTH_HERE" %SWF_WIDTH% %DESTINATION_PATH%\index_polite4.html>%DESTINATION_PATH%\index_polite5.html

CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_HEIGHT_HERE" %SWF_HEIGHT% %DESTINATION_PATH%\index_polite5.html>%DESTINATION_PATH%\index_polite6.html

del %DESTINATION_PATH%\index_polite.html >nul 2>&1
del %DESTINATION_PATH%\index_polite2.html >nul 2>&1
del %DESTINATION_PATH%\index_polite3.html >nul 2>&1
del %DESTINATION_PATH%\index_polite4.html >nul 2>&1
del %DESTINATION_PATH%\index_polite5.html >nul 2>&1

rename %DESTINATION_PATH%\index_polite6.html index_polite.html


REM ********************** Customize index_B.html **********************

if exist %DESTINATION_PATH%\index_B.html (

	ECHO Customizing index_B.html...

	ECHO.

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_ENVIRONMENT_NAME_HERE" %DESTINATION_ENVIRONMENT% %DESTINATION_PATH%\index_B.html>%DESTINATION_PATH%\index_B_2.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_TEMPLATE_ID_HERE" %TEMPLATE_ID% %DESTINATION_PATH%\index_B_2.html>%DESTINATION_PATH%\index_B_3.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_FACECAKE_APP_VERSION_NUMBER_HERE" %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_PATH%\index_B_3.html>%DESTINATION_PATH%\index_B_4.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_WIDTH_HERE" %SWF_WIDTH% %DESTINATION_PATH%\index_B_4.html>%DESTINATION_PATH%\index_B_5.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_HEIGHT_HERE" %SWF_HEIGHT% %DESTINATION_PATH%\index_B_5.html>%DESTINATION_PATH%\index_B_6.html

	del %DESTINATION_PATH%\index_B.html >nul 2>&1
	del %DESTINATION_PATH%\index_B_2.html >nul 2>&1
	del %DESTINATION_PATH%\index_B_3.html >nul 2>&1
	del %DESTINATION_PATH%\index_B_4.html >nul 2>&1
	del %DESTINATION_PATH%\index_B_5.html >nul 2>&1

	rename %DESTINATION_PATH%\index_B_6.html index_B.html

)


REM ********************** Customize index_polite_load_animation_a.html **********************

if exist %DESTINATION_PATH%\index_polite_load_animation_a.html (

	ECHO Customizing index_polite_load_animation_a.html...

	ECHO.

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_ENVIRONMENT_NAME_HERE" %DESTINATION_ENVIRONMENT% %DESTINATION_PATH%\index_polite_load_animation_a.html>%DESTINATION_PATH%\index_polite_load_animation_a_2.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_TEMPLATE_ID_HERE" %TEMPLATE_ID% %DESTINATION_PATH%\index_polite_load_animation_a_2.html>%DESTINATION_PATH%\index_polite_load_animation_a_3.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_FACECAKE_APP_VERSION_NUMBER_HERE" %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_PATH%\index_polite_load_animation_a_3.html>%DESTINATION_PATH%\index_polite_load_animation_a_4.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_WIDTH_HERE" %SWF_WIDTH% %DESTINATION_PATH%\index_polite_load_animation_a_4.html>%DESTINATION_PATH%\index_polite_load_animation_a_5.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_HEIGHT_HERE" %SWF_HEIGHT% %DESTINATION_PATH%\index_polite_load_animation_a_5.html>%DESTINATION_PATH%\index_polite_load_animation_a_6.html

	del %DESTINATION_PATH%\index_polite_load_animation_a.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_a_2.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_a_3.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_a_4.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_a_5.html >nul 2>&1

	rename %DESTINATION_PATH%\index_polite_load_animation_a_6.html index_polite_load_animation_a.html

)


REM ********************** Customize index_polite_load_animation_b.html **********************

if exist %DESTINATION_PATH%\index_polite_load_animation_b.html (

	ECHO Customizing index_polite_load_animation_b.html...

	ECHO.

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_ENVIRONMENT_NAME_HERE" %DESTINATION_ENVIRONMENT% %DESTINATION_PATH%\index_polite_load_animation_b.html>%DESTINATION_PATH%\index_polite_load_animation_b_2.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_TEMPLATE_ID_HERE" %TEMPLATE_ID% %DESTINATION_PATH%\index_polite_load_animation_b_2.html>%DESTINATION_PATH%\index_polite_load_animation_b_3.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_FACECAKE_APP_VERSION_NUMBER_HERE" %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_PATH%\index_polite_load_animation_b_3.html>%DESTINATION_PATH%\index_polite_load_animation_b_4.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_WIDTH_HERE" %SWF_WIDTH% %DESTINATION_PATH%\index_polite_load_animation_b_4.html>%DESTINATION_PATH%\index_polite_load_animation_b_5.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_HEIGHT_HERE" %SWF_HEIGHT% %DESTINATION_PATH%\index_polite_load_animation_b_5.html>%DESTINATION_PATH%\index_polite_load_animation_b_6.html

	del %DESTINATION_PATH%\index_polite_load_animation_b.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_b_2.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_b_3.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_b_4.html >nul 2>&1
	del %DESTINATION_PATH%\index_polite_load_animation_b_5.html >nul 2>&1

	rename %DESTINATION_PATH%\index_polite_load_animation_b_6.html index_polite_load_animation_b.html

)


REM ********************** Customize index_plain.html **********************

if exist %DESTINATION_PATH%\index_plain.html (

	ECHO Customizing index_plain.html...

	ECHO.

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_ENVIRONMENT_NAME_HERE" %DESTINATION_ENVIRONMENT% %DESTINATION_PATH%\index_plain.html>%DESTINATION_PATH%\index_plain_2.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_TEMPLATE_ID_HERE" %TEMPLATE_ID% %DESTINATION_PATH%\index_plain_2.html>%DESTINATION_PATH%\index_plain_3.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_FACECAKE_APP_VERSION_NUMBER_HERE" %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_PATH%\index_plain_3.html>%DESTINATION_PATH%\index_plain_4.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_WIDTH_HERE" %SWF_WIDTH% %DESTINATION_PATH%\index_plain_4.html>%DESTINATION_PATH%\index_plain_5.html

	CALL %BATCH_PATH%\batchSubstitute.bat "INSERT_SWF_HEIGHT_HERE" %SWF_HEIGHT% %DESTINATION_PATH%\index_plain_5.html>%DESTINATION_PATH%\index_plain_6.html

	del %DESTINATION_PATH%\index_plain.html >nul 2>&1
	del %DESTINATION_PATH%\index_plain_2.html >nul 2>&1
	del %DESTINATION_PATH%\index_plain_3.html >nul 2>&1
	del %DESTINATION_PATH%\index_plain_4.html >nul 2>&1
	del %DESTINATION_PATH%\index_plain_5.html >nul 2>&1

	rename %DESTINATION_PATH%\index_plain_6.html index_plain.html

)


REM ********************** Customize config.xml **********************

ECHO Customizing config.xml...

ECHO.

CALL %BATCH_PATH%\batchSubstitute.bat "/dev/" /%DESTINATION_ENVIRONMENT%/ %DESTINATION_PATH%\xml\config.xml>%DESTINATION_PATH%\xml\config2.xml

CALL %BATCH_PATH%\batchSubstitute.bat "/dev/tob" /%DESTINATION_ENVIRONMENT%/%PRODUCT_NAME% %DESTINATION_PATH%\xml\config2.xml>%DESTINATION_PATH%\xml\config3.xml

CALL %BATCH_PATH%\batchSubstitute.bat "img/" http://media.facecake.com/%DESTINATION_ENVIRONMENT%/%PRODUCT_NAME%/%TEMPLATE_ID%/img/ %DESTINATION_PATH%\xml\config3.xml>%DESTINATION_PATH%\xml\config4.xml

CALL %BATCH_PATH%\batchSubstitute.bat "tryOnViewBackgroundAnimation" http://cache.facecake.com/%DESTINATION_ENVIRONMENT%/%PRODUCT_NAME%/%TEMPLATE_ID%/tryOnViewBackgroundAnimation %DESTINATION_PATH%\xml\config4.xml>%DESTINATION_PATH%\xml\config5.xml

CALL %BATCH_PATH%\batchSubstitute.bat "http://media.facecake.com" http://media.facecake.com %DESTINATION_PATH%\xml\config5.xml>%DESTINATION_PATH%\xml\config6.xml

del %DESTINATION_PATH%\xml\config.xml >nul 2>&1

del %DESTINATION_PATH%\xml\config2.xml >nul 2>&1

del %DESTINATION_PATH%\xml\config3.xml >nul 2>&1

del %DESTINATION_PATH%\xml\config4.xml >nul 2>&1

del %DESTINATION_PATH%\xml\config5.xml >nul 2>&1

IF %DESTINATION_ENVIRONMENT% == prod (
     
     CALL %BATCH_PATH%\batchSubstitute.bat "ecfdev.facecake.com" "ecf.facecake.com" %DESTINATION_PATH%\xml\config6.xml>%DESTINATION_PATH%\xml\config7.xml
     
     del %DESTINATION_PATH%\xml\config.xml >nul 2>&1
     del %DESTINATION_PATH%\xml\config2.xml >nul 2>&1
     del %DESTINATION_PATH%\xml\config3.xml >nul 2>&1
     del %DESTINATION_PATH%\xml\config4.xml >nul 2>&1
     del %DESTINATION_PATH%\xml\config5.xml >nul 2>&1
     del %DESTINATION_PATH%\xml\config6.xml >nul 2>&1
     
     rename %DESTINATION_PATH%\xml\config7.xml config.xml
     
) ELSE (

     del %DESTINATION_PATH%\xml\config.xml >nul 2>&1

     del %DESTINATION_PATH%\xml\config2.xml >nul 2>&1

     del %DESTINATION_PATH%\xml\config3.xml >nul 2>&1

     del %DESTINATION_PATH%\xml\config4.xml >nul 2>&1

     del %DESTINATION_PATH%\xml\config5.xml >nul 2>&1

     rename %DESTINATION_PATH%\xml\config6.xml config.xml
     
)

REM ********************** Success and Reminders **********************

ECHO DEPLOYMENT OF TRY-ON BANNER %PRODUCT_TYPE% %TEMPLATE_ID% VERSION: %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_ENVIRONMENT% COMPLETED.

ECHO.

ECHO IMPORTANT REMINDERS !!!

ECHO.

ECHO Remember to clear your local cache and refresh the Mirror Image CDN cache.
ECHO.
ECHO Please wait 10 minutes before testing to be sure deployed files have propagated to CDN servers.
ECHO.
IF %HAS_DOUBLECLICK_TRACKING%==true (
	ECHO Be sure to upload DoubleClick files to the DoubleClick Studio creative for this banner
	ECHO.
	ECHO before testing via DoubleClick Studio Interface.
	ECHO.
)

pause


REM ********************** Functions **********************

:ClearScreen
CLS
ECHO.
ECHO DEPLOY: TRY-ON BANNER %PRODUCT_TYPE% %TEMPLATE_ID% VERSION: %FACECAKE_APP_VERSION_NUMBER% %DESTINATION_ENVIRONMENT%
ECHO.
GOTO:EOF

:CheckVersionNumberFormat
SET TEMP_VERSION_NUMBER=%FACECAKE_APP_VERSION_NUMBER:.=,%
SET /A COUNT=0
SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%i IN (%TEMP_VERSION_NUMBER%) DO (
  SET /A COUNT=COUNT+1
)
IF !COUNT! LSS 3 (
	ECHO.
	ECHO Version is wrong format.  Try again.
	ECHO.
	ECHO.
	GOTO:EnterFaceCakeVersionNumber
)
GOTO:EOF