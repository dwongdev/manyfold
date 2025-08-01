require "rails_helper"

RSpec.describe "Comments" do
  context "when on a public item in multiuser mode", :multiuser do
    let(:user) { create(:user) }
    let(:model) { create(:model, :public) }
    let(:comment) { model.comments.create(commenter: user, comment: Faker::Lorem.paragraph) }

    describe "GET #show" do
      context "when requesting ActivityPub JSON" do
        before do
          get "/models/#{model.public_id}/comments/#{comment.public_id}", headers: {accept: "application/activity+json"}
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "returns activitypub" do
          expect(response.content_type).to start_with "application/ld+json"
        end

        it "returns a Note" do
          expect(response.parsed_body["type"]).to eq "Note"
        end

        it "includes standard JSON-LD context" do
          expect(response.parsed_body["@context"]).to include("https://www.w3.org/ns/activitystreams")
        end

        it "includes extended JSON-LD context" do
          expect(response.parsed_body["@context"]).to include("https://purl.archive.org/miscellany")
        end
      end
    end
  end
end
