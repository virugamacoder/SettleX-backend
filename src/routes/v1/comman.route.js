const express = require('express');
const {onlyadmin} = require('../../middlewares/auth');
const { uploadStorage } = require('../../utils/upload');
const { sendSuccessResponse } = require('../../utils/ApiResponse');
const httpStatus = require('http-status');
const config = require('../../config/config');
const catchAsync = require('../../utils/catchAsync');


const router = express.Router();

router.post('/upload/', uploadStorage.single('file'), catchAsync((req, res) => {
  if (!req.file) {
    return res.status(400).json({ status: 'fail', message: 'No file uploaded' });
  }
  const protocol = req.headers['x-forwarded-proto'] || req.protocol;
  const host = req.headers['x-forwarded-host'] || req.get('host');
  const fileUrl = `${protocol}://${host}/${req.file.path}`;
  sendSuccessResponse(res, 'file uploaded successfully', fileUrl, httpStatus.CREATED);
}));

module.exports = router;
