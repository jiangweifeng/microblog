import { createActor, microblog } from "../../declarations/microblog";

async function post() {
  let post_button = document.getElementById("post");
  let err_msg = document.getElementById("error");
  err_msg.innerText = ""
  post_button.disabled = true;
  let textarea = document.getElementById("message");
  let password = document.getElementById("password").value;
  let text = textarea.value;
  try {
    await microblog.post(text, password.trim());
  } catch (error) {
    console.log(error);
    err_msg.innerText = "Post Failed";
  }
  post_button.disabled = false;
}

var num_posts = 0;

var users_posts = {};

async function load_timeline() {
  let posts_section = document.getElementById("posts");
  let posts = await microblog.timeline();
  if (num_posts == posts.length) return;
  posts_section.replaceChildren([]);
  num_posts = posts.length;
  /*
<blockquote>
  <p>Friends don’t spy; true friendship is about privacy, too.</p>
  <p><cite>– Stephen King</cite></p>
</blockquote>
  */
  for (var i = 0; i < posts.length; i++) {
    let post = document.createElement("blockquote");
    let postmsg = posts[i];
    let datetime = (new Date(Number(postmsg.time / 1000000n))).toLocaleString();
    let msg = post.appendChild(document.createElement('p'));
    msg.innerText = postmsg.content;
    let author = post.appendChild(document.createElement('p')).appendChild(document.createElement('cite'));
    author.innerText = postmsg.author;
    let datetimearea = post.appendChild(document.createElement('p')).appendChild(document.createElement('cite'));
    datetimearea.innerText = datetime;
    posts_section.appendChild(post);
  }
}
var num_follows = 0;

async function load_follows() {
  let follows_section = document.getElementById("follows");
  let follows = await microblog.follows();
  if (follows.length == num_follows) return;
  follows_section.replaceChildren([]);
  num_follows = follows.length;
  for (var i = 0; i < follows.length; i++) {
    let blog = createActor(follows[i]);
    let blog_name = await blog.get_name();
    let btn = document.createElement('button');
    btn.innerText = blog_name + " (" + follows[i] + ")";
    let id = follows[i].toText();
    btn.onclick = () => load_posts(id, blog_name);
    follows_section.appendChild(btn)
    follows_section.appendChild(document.createElement("br"));
  }
}

async function load_posts(id, name) {
  document.getElementById("main_div").hidden = true;
  document.getElementById("posts_div").hidden = false;

  document.getElementById("posts_title").innerText = name;
  let personal_posts = document.getElementById("personal_posts");
  personal_posts.replaceChildren([]);
  let p = createActor(id);
  let posts = await p.posts();
  for (var i = 0; i < posts.length; i++) {
    let post = document.createElement("blockquote");
    let postmsg = posts[i];
    let datetime = (new Date(Number(postmsg.time / 1000000n))).toLocaleString();
    let msg = post.appendChild(document.createElement('p'));
    msg.innerText = postmsg.content;
    let author = post.appendChild(document.createElement('p')).appendChild(document.createElement('cite'));
    author.innerText = postmsg.author;
    let datetimearea = post.appendChild(document.createElement('p')).appendChild(document.createElement('cite'));
    datetimearea.innerText = datetime;
    personal_posts.appendChild(post);
  }
}

function load() {
  document.getElementById("main_div").hidden = false;
  document.getElementById("posts_div").hidden = true;
  let homepage = document.getElementById("homepage");
  homepage.onclick = () => {
    document.getElementById("main_div").hidden = false;
    document.getElementById("posts_div").hidden = true;
  };

  let post_button = document.getElementById("post");
  post_button.onclick = post;
  load_follows();
  load_timeline();
  setInterval(load_timeline, 3000);
  setInterval(load_follows, 10000);
}

window.onload = load;