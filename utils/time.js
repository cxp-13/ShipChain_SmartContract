function isTimeZone(offset) {
    // 获取当前本地时间
    var now = new Date();

    // 获取本地时区与 UTC 时间相差的分钟数
    var localOffset = now.getTimezoneOffset();
    console.log("localOffset", localOffset);

    // 计算指定时区与 UTC 时间相差的分钟数
    var targetOffset = -(offset * 60);

    // 比较两个时区的分钟数是否相等
    return localOffset === targetOffset;
}
module.exports = isTimeZone;
