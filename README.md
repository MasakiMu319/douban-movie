# douban-movie

## 综述

这是一个入门级的爬虫案例，功能是爬取豆瓣电影TOP 250（蛤？你要问为什么是 250 ？？？可能得去找一下豆瓣程序员了😀）

## 分析

首先我们需要分析一下单个目标信息：

![image-20210923234308097](https://typora-photos.oss-cn-shenzhen.aliyuncs.com/img/image-20210923234308097.png)

如图中标志出的每个电影共同需要的信息类型，然后定位其在页面的字段位置进行提取就好。

整体目标源是单个页面：

- 一共有 10 页，每页包含 25 个单体目标信息；
- 单体目标信息的排序都是固定的。

## 开始

在数据量不大的时候，我们可以直接对目标进行爬取：

- 分析页面，得到每个页面的信息（☞ 跳转 url）
- 分析页面，循环爬取所有页面的电影信息
- 将爬取的电影信息进行持久化处理

### 安装

这是我们调用的页面分析库 `goquery`：

```shell
go get -u github.com/PuerkitoBio/goquery
```

### 运行

```shell
go run main,go
```

正常情况下控制台会输出如下日志以及数据库信息（部分）：

![image-20210923235257249](https://typora-photos.oss-cn-shenzhen.aliyuncs.com/img/image-20210923235257249.png)

### 核心代码

#### 1. 模拟客户端进行访问

```go
func GetDoc(url string) (*goquery.Document, error) {
	client := &http.Client{}
	request, _ := http.NewRequest("GET", url, nil)
	request.Header.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36 Edg/93.0.961.52")
	res, _ := client.Do(request)
	return goquery.NewDocumentFromReader(res.Body)
}
```

这里我们采用 `Golang` 自带的 `Client` 进行模拟，如果直接使用 `net/http` 库中的 `Get` 方法会返回错误码 `418`（具体含义是啥我不解释，感兴趣自己查）。

#### 2. 获取分页

```go
func GetPages(url string) []Page {
	doc, err := GetDoc(url)
	if err != nil {
		log.Fatal(err)
	}

	return ParsePages(doc)
}
```

这里其实没什么要做的，关键的页面步骤是在 `ParsePage` 中完成的，这里独立出来只是为了让模拟客户端的方法得到复用，毕竟相同逻辑的事情一次解决不是更好吗？

#### 3. 分析分页

```go
func ParsePages(doc *goquery.Document) (pages []Page) {
	pages = append(pages, Page{Page: 1, Url: ""})
	doc.Find("div.paginator > a").Each(func(i int, s *goquery.Selection) {
		page, _ := strconv.Atoi(s.Text())
		url, _ := s.Attr("href")

		pages = append(pages, Page{
			Page: page,
			Url:  url,
		})
	})

	return pages
}
```

这里我们调用 `goquery` 库的 `Find` 方法来定位具有页面信息标签，注意这里的标签不是瞎写或者猜的，浏览器 F12 自己定位一下就有了。

#### 4. 分析电影数据

```go
func ParseMovies(doc *goquery.Document) (movies []DoubanMovie) {
	doc.Find("#content > div > div.article > ol > li").Each(func(i int, s *goquery.Selection) {
		title := s.Find(".hd a span").Eq(0).Text()

		...

		movieDesc := strings.Split(DescInfo[1], "/")
		year := strings.TrimSpace(movieDesc[0])
		area := strings.TrimSpace(movieDesc[1])
		tag := strings.TrimSpace(movieDesc[2])

		star := s.Find(".bd .star .rating_num").Text()

		comment := strings.TrimSpace(s.Find(".bd .star span").Eq(3).Text())
		compile := regexp.MustCompile("[0-9]")
		comment = strings.Join(compile.FindAllString(comment, -1), "")

		quote := s.Find(".quote .inq").Text()

		...

		log.Printf("i: %d, movie: %v", i, movie)

		movies = append(movies, movie)
	})

	return movies
}
```

电影具体信息的获取类似于页码拆分，都是对页面标签数据进行提取，然后存储在我们建好的结构体中就好。

#### 5. 数据库

写入数据库的操作很简单，省略 ...
