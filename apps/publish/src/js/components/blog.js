import React, { Component } from 'react';
import classnames from 'classnames';
import { PostPreview } from '/components/post-preview';
import _ from 'lodash';
import { PathControl } from '/components/lib/path-control';
import { withRouter } from 'react-router';

const PC = withRouter(PathControl);


export class Blog extends Component {
  constructor(props){
    super(props);

    this.state = {
      awaiting: false,
      postProps: [],
      blogTitle: '',
      blogHost: '',
      pathData: [],
    };
  }

  handleEvent(diff) {
    console.log("handleEvent", diff);

    if (diff.data.total) {
      let blog = diff.data.total.data;
      this.setState({
        postProps: this.buildPosts(blog),
        blogTitle: blog.info.title,
        blogHost: blog.info.owner,
        awaiting: false,
        pathData: [
          { text: "Home", url: "/~publish/recent" },
          { text: blog.info.title, 
            url: `/~publish/${blog.info.owner}/${blog.info.filename}` }
        ],
      });
    }
  }

  handleError(err) {
    console.log("handleError", err);
  }

  componentWillMount() {
    if (this.props.ship != window.ship) {
      let ship = this.props.ship;
      let blogId = this.props.blogId;
      let blog = _.get(this.props,
        `subs[${ship}][${blogId}]`, false);

      if (blog) {
        this.setState({
          postProps: this.buildPosts(blog),
          blogTitle: blog.info.title,
          blogHost: blog.info.owner,
          awaiting: false,
          pathData: [
            { text: "Home", url: "/~publish/recent" },
            { text: blog.info.title, 
              url: `/~publish/${blog.info.owner}/${blog.info.filename}` }
          ],
        });
      } else {
        this.setState({
          awaiting: {
            ship: ship,
            blogId: blogId,
          }
        });

        this.props.api.bind(`/collection/${blogId}`, "PUT", ship, "write",
          this.handleEvent.bind(this),
          this.handleError.bind(this));
      }
    } else {
      let ship = this.props.ship;
      let blogId = this.props.blogId;
      let blog = _.get(this.props,
        `pubs[${blogId}]`, false);
      this.setState({
        postProps: this.buildPosts(blog),
        blogTitle: blog.info.title,
        blogHost: blog.info.owner,
        awaiting: false,
        pathData: [
          { text: "Home", url: "/~publish/recent" },
          { text: blog.info.title, 
            url: `/~publish/${blog.info.owner}/${blog.info.filename}` }
        ],
      });
    }
  }


  buildPosts(blog){
    let pinProps = blog.order.pin.map((postId) => {
      let post = blog.posts[postId];
      return this.buildPostPreviewProps(post, blog, true);
    });

    let unpinProps = blog.order.unpin.map((postId) => {
      let post = blog.posts[postId];
      return this.buildPostPreviewProps(post, blog, false);
    });

    return pinProps.concat(unpinProps);
  }

  buildPostPreviewProps(post, blog, pinned){
    return {
      postTitle: post.post.info.title,
      postName:  post.post.info.filename,
      postBody: post.post.body,
      numComments: post.comments.length,
      collectionTitle: blog.info.title,
      collectionName:  blog.info.filename,
      author: post.post.info.creator,
      blogOwner: blog.info.owner,
      date: post.post.info["date-created"],
      pinned: pinned,
    }

  }

  render() {
    let posts = this.state.postProps.map((post, key) => {
      return (
        <PostPreview
          post={post}
          key={key}
        />
      );
    });

    let contributers = " and X others";       // XX backend work
    let subscribers = "~bitpyx-dildus and X others"; // XX backend work

    if (this.state.awaiting) {
      return (
        <div className="w-100 ba h-inner">
          Loading
        </div>
      );
    } else {
      return (
        <div>
          <div className="cf w-100 bg-white h-publish-header">
            <PathControl pathData={this.state.pathData}/>
          </div>
          <div className="flex-col">
            <h2>{this.state.blogTitle}</h2>
            <div className="flex">
              <div style={{flexBasis: 350}}>
                <p>Host</p>
                <p>{this.state.blogHost}</p>
              </div>
              <div style={{flexBasis: 350}}>
                <p>Contributors</p>
                <p>{contributers}</p>
              </div>
              <div style={{flexBasis: 350}}>
                <p>Subscribers</p>
                <p>{subscribers}</p>
              </div>
            </div>
            <div className="flex flex-wrap">
              {posts}
            </div>
          </div>
        </div>
      );
    }
  }
}

