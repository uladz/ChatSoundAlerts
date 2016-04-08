#!/bin/bash

ADDON=$(ls *.txt | awk 'BEGIN{FS="."}{print $1}')
if [ "${ADDON}" == "" ]; then
  echo "Manifest file for addon in not found"
  exit 1
fi
if (( "$(echo ${ADDON} | wc -w)" > 1 )); then
  echo "Found more than one manifest file, must be one"
  exit 1
fi
MANIFEST=${ADDON}.txt
VERSION=$(grep "## Version:" ${MANIFEST} | awk '{print $3}')
if [ "$VERSION" == "" ]; then
  echo "Version is not found in manifest \"${MANIFEST}\""
  exit 1
fi
echo "Preparing release for ${ADDON} v${VERSION}"

CHECK_CHANGELOG=$(grep "${VERSION}" CHANGELOG)
if [ "${CHECK_CHANGELOG}" == "" ]; then
  echo "ERROR: Changelog does not have entry for v${VERSION}"
  exit 1
fi
CHECK_TITLE=$(grep "## Title:" ${MANIFEST})
if [ "$CHECK_TITLE" == "" ]; then
  echo "Title is not found in manifest \"${MANIFEST}\""
  exit 1
fi
if [[ ! $CHECK_TITLE =~ ^.+${VERSION}.+$ ]]; then
  echo "Title version is not up-to-date in manifest \"${MANIFEST}\""
  exit 1
fi
LUA=${ADDON}.lua
CHECK_LUA=$(grep -m1 "version" ${LUA})
if [ "$CHECK_TITLE" == "" ]; then
  echo "Main LUA file \"${LUA}\" is not found"
  exit 1
fi
if [[ ! $CHECK_LUA =~ ^.+${VERSION}.+$ ]]; then
  echo "Addon version is not up-to-date in \"${LUA}\""
  exit 1
fi
echo "Everything looks good"

TMP_DIR=/tmp/${ADDON}
echo "Cleaning up addon in staging directory ${TMP_DIR}"
mkdir ${TMP_DIR}
cp -r ./* ${TMP_DIR}
rm -rf ${TMP_DIR}/.git*
rm -rf ${TMP_DIR}/.idea
rm -rf ${TMP_DIR}/*.iml
rm -rf ${TMP_DIR}/*.sh

ADDON_ZIP=${ADDON}-${VERSION}.zip
echo "Zipping up ${ADDON_ZIP}"
pushd ${TMP_DIR}/..
rm -rf ${ADDON_ZIP}
zip -9 -r ${ADDON_ZIP} ${ADDON}
popd
mv -f ${TMP_DIR}/../${ADDON_ZIP} .
rm -rf ${TMP_DIR}
