CREATE TABLE `sp_douban_movie` (
    `id` INT ( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR ( 50 ) DEFAULT '' COMMENT '标题',
    `subtitle` VARCHAR ( 100 ) DEFAULT '' COMMENT '副标题',
    `other` VARCHAR ( 100 ) DEFAULT '' COMMENT '其他',
    `desc` VARCHAR ( 200 ) DEFAULT '' COMMENT '简述',
    `year` VARCHAR ( 20 ) DEFAULT '' COMMENT '年份',
    `area` VARCHAR ( 200 ) DEFAULT '' COMMENT '地区',
    `tag` VARCHAR ( 200 ) DEFAULT '' COMMENT '标签',
    `star` INT ( 10 ) UNSIGNED DEFAULT '0' COMMENT 'star',
    `comment` INT ( 10 ) UNSIGNED DEFAULT '0' COMMENT '评分',
    `quote` VARCHAR ( 200 ) DEFAULT '' COMMENT '引用',
    PRIMARY KEY ( `id` )
) ENGINE = INNODB DEFAULT CHARSET = utf8 COMMENT = '豆瓣电影Top250';