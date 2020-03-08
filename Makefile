SDK=${HOME}/.AndroidSdk
BUILD_TOOLS=29.0.3
PLATFORM=android-29
ANDROID_JAR=${SDK}/platforms/${PLATFORM}/android.jar
AAPT2=${SDK}/build-tools/${BUILD_TOOLS}/aapt2
D8=${SDK}/build-tools/${BUILD_TOOLS}/d8
ZIPALIGN=${SDK}/build-tools/${BUILD_TOOLS}/zipalign
APKSIGNER=${SDK}/build-tools/${BUILD_TOOLS}/apksigner
release.apk: cert.key
	rm -rf build
	mkdir -p build/classes
	${AAPT2} compile --dir res -o build/res.zip
	${AAPT2} link build/res.zip -o build/res.apk --manifest AndroidManifest.xml -I ${ANDROID_JAR} --java build/generated
	unzip build/res.apk -d build/apk
	find build/generated src -type f -print0 | xargs -0 javac -O -g:none -d build/classes -bootclasspath ${ANDROID_JAR}
	find build/classes -type f -print0 | xargs -0 ${D8} --release --lib ${ANDROID_JAR} --output build/apk
	cd build/apk && find -type f -print0 | sort -z -f | xargs -0 zip -DJXr9 ../unaligned.apk
	${ZIPALIGN} 4 build/unaligned.apk build/unsigned.apk
	openssl pkcs8 -outform DER -topk8 -in cert.key -out build/cert.pk8 -nocrypt
	tools/selfsign.py cert.key build/cert.crt "Android App Signing Key"
	${APKSIGNER} sign --key build/cert.pk8 --cert build/cert.crt --out release.apk build/unsigned.apk
cert.key:
	openssl genrsa 2048 > cert.key
